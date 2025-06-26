#!/bin/bash

# Lakasir POS deployment script
# Supported App Version: 1.1.5
# Supported OS: Ubuntu
# Author: Yogi Saputro

set -e

SCRIPT_VERSION="v1.0.0"

REPO_URL="https://github.com/lakasir/lakasir.git" # Please support the original author.
APP_DIR="lakasir-pos"
APP_VERSION="1.1.5"
PHP_VERSION="8.2"

DB_USER=${1:-DEFAULT_USER}            # input for MySQL User with default value
DB_PASS=${2:-DEFAULT_PASSWORD}        # input for MySQL password with default value
DB_NAME=${3:-pos_db}                  # input for MySQL DB name with default value

echo "=== Starting Lakasir POS Deployment Script ${SCRIPT_VERSION} ==="

# 1. Repository installation step
cd $HOME

if [ ! -d "$APP_DIR" ]; then
  echo "Cloning repository..."
  git clone --branch "$APP_VERSION" --depth 1 "$REPO_URL" "$APP_DIR"
else
  echo "Repository already exists. Skipping clone..."
fi

cd "$APP_DIR"

# 2. PHP Installation Step
if ! php -v | grep -q "8.2"; then
  echo "Installing PHP 8.2..."
  sudo apt install -y software-properties-common
  sudo add-apt-repository ppa:ondrej/php ppa:ondrej/nginx -y
  sudo apt update

  sudo apt install -y nginx php$PHP_VERSION php$PHP_VERSION-{fpm,cli,mbstring,bcmath,xml,zip,curl,common,mysql,intl,gd}

  sudo update-alternatives --set php /usr/bin/php8.2

  sudo systemctl enable php$PHP_VERSION-fpm
  sudo systemctl start php$PHP_VERSION-fpm

else
  echo "PHP 8.2 is already installed. Skipping PHP installation..."
fi

# 3. MySQL Installation Step
if ! mysql --version; then
  echo "Installing MySQL ..."
  sudo apt update
  sudo apt install -y mysql-server
  sudo systemctl enable mysql
  sudo systemctl start mysql
  echo "Configuring MySQL..."

  SQL=$(cat <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF
)

  sudo mysql -u root -e "$SQL"

else
  echo "MySQL 5.7+ is already installed. Skipping MySQL installation..."
fi

# 4. Install Redis if not installed
if ! command -v redis-server &> /dev/null; then
  echo "Installing Redis..."
  sudo apt update
  sudo apt install -y redis-server
  sudo systemctl enable redis-server
  sudo systemctl start redis-server
else
  echo "Redis is already installed. Skipping Redis installation..."
fi


# 5. Check if curl is installed
if ! command -v curl &> /dev/null; then
  echo "Installing curl..."
  sudo apt update
  sudo apt install -y curl
else
  echo "curl is already installed. Continuing..."
fi

# 6. Setup Composer
if ! command -v composer &> /dev/null; then
  echo "Installing Composer..."
  curl -sS https://getcomposer.org/installer | php
  sudo mv composer.phar /usr/local/bin/composer
else
  echo "Composer is already installed. Skipping Composer setup..."
fi

# 7. Install Node.js and NPM if not installed
if ! command -v npm &> /dev/null; then
  echo "Installing Node.js and NPM..."
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt install -y nodejs
else
  echo "NPM is already installed. Skipping NPM installation..."
fi

# 8. Laravel setup
echo "Running Laravel setup..."

if [ ! -f ".env" ]; then
  cp .env.example .env
  echo ".env created from .env.example"
fi

echo "Updating .env credentials..."
sed -i "s/^DB_DATABASE=.*/DB_DATABASE=${DB_NAME}/" .env
sed -i "s/^DB_USERNAME=.*/DB_USERNAME=${DB_USER}/" .env
sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=${DB_PASS}/" .env
sed -i "s/^APP_ENV=.*/APP_ENV=production/" .env
sed -i "s/^APP_DEBUG=.*/APP_DEBUG=false/" .env
sed -i "s/^APP_LOCAL=.*/APP_LOCAL=id/" .env

composer install

php artisan key:generate
php artisan migrate --path=database/migrations/tenant --seed
php artisan filament:assets
php artisan livewire:publish --assets

npm install
npm run build

if ! timeout 20s php artisan app:create-user; then
  echo "app:create-user command failed or timed out"
fi

echo "=== POS Deployment Completed ==="

echo "running in production"
php artisan serve

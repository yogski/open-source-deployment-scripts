# OSDES - Open Source Deployment Scripts

**OSDES** is an open source collection of ready-to-use deployment scripts for highly-starred GitHub repositories that **lack proper setup, deployment, or installation automation**.

Mission:  
💡 **Make great open source projects easy to run in the real world.**

---

## ✅ What This Repo Offers

- **Turnkey deployment scripts** for selected GitHub repositories
- Designed for **Ubuntu 20.04+** (VM or server) - more OS coming soon.
- Includes setup of:
  - Required runtimes (PHP, Node.js, Python, etc.)
  - Dependencies (Composer, NPM, Pip, etc.)
  - Databases (MySQL, PostgreSQL, SQLite, etc.)
  - Project-specific configuration (.env files, keys, assets)
- **Optional arguments** to customize installs (e.g., DB user/password)
- Scripts are **idempotent** (re-running is safe)

---

## 📦 Why This Exists

Many amazing open source projects:
- Have hundreds of stars ⭐
- Solve real-world problems 🔧
- But... are **hard to deploy** 😩

This repo bridges the gap between _"cool project"_ and _"usable in production"_, especially for developers, small teams, and IT pros.

---

## 📂 Included Scripts

| Project Name             | Language / Stack         | Script Path                          |
|--------------------------|--------------------------|--------------------------------------|
| [`lakasir`](https://github.com/lakasir/lakasir)            | PHP 8.1 / Laravel / MySQL| [`apps/lakasir/lakasir-ubuntu-v1.sh`](apps/lakasir/lakasir-ubuntu-v1.sh) |
<!-- Add more as you grow -->

---

## 🛠 How to Use

```bash
# Clone the repo
git clone https://github.com/yogski/open-source-deployment-scripts.git
cd open-source-deployment-scripts/apps/your_app_name

# Run the script (example)
./app-ubuntu.sh --db_user=myuser --db_pass=mypassword

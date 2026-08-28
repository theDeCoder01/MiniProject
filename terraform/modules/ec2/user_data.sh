#!/bin/bash
set -euxo pipefail

# Log all output to /var/log/user-data.log
exec > >(tee -a /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y software-properties-common git curl

add-apt-repository -y ppa:deadsnakes/ppa
apt-get update -y
apt-get install -y python3.11 python3.11-venv python3.11-dev

# Create app user and installation directory
useradd --system --shell /bin/false --home-dir /opt/todo-api todoapi
mkdir -p /opt/todo-api

# Dynamic GitHub Repo URL passed from Terraform
git clone -b main ${repo_url} /opt/todo-api/MiniProject

# Setup venv and install dependencies
python3.11 -m venv /opt/todo-api/venv
/opt/todo-api/venv/bin/pip install --upgrade pip
/opt/todo-api/venv/bin/pip install -r /opt/todo-api/MiniProject/mini-project1/app/requirements.txt
/opt/todo-api/venv/bin/pip install gunicorn

chown -R todoapi:todoapi /opt/todo-api

# Create Systemd service using dynamic app port
cat << 'EOF' > /etc/systemd/system/todo-api.service
[Unit]
Description=Todo API Flask Application
After=network.target

[Service]
User=todoapi
WorkingDirectory=/opt/todo-api/MiniProject/mini-project1/app
ExecStart=/opt/todo-api/venv/bin/gunicorn --workers 1 --bind 0.0.0.0:${app_port} main:app
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Grant 'ubuntu' user sudo permissions to restart service
cat << 'EOF' > /etc/sudoers.d/todoapi-deploy
ubuntu ALL=(ALL) NOPASSWD: /bin/systemctl restart todo-api, /bin/systemctl stop todo-api, /bin/systemctl start todo-api, /bin/systemctl status todo-api
EOF
chmod 0440 /etc/sudoers.d/todoapi-deploy

systemctl daemon-reload
systemctl enable --now todo-api
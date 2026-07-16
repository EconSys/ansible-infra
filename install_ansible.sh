#! /usr/bin/env bash
set -euo pipefail

# create/reuse Ansible environment; protect against breaking package dependencies
VENV_DIR=".ansible_venv"
 
if [ ! -d "$VENV_DIR" ]; then
  python3 -m venv "$VENV_DIR"
fi

# Activate Ansible Virtual Environment and drop into shell
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

# upgrade pip
python3 -m pip install --upgrade pip

# AWS, Ansible, and other required dependencies
python3 -m pip install -r requirements.txt || exit 1

ansible --version
ansible-playbook --version
ansible-lint --version
python3 -m pip list

# required Ansible Galaxy Collections
ansible-galaxy collection install -r requirements.yml

# add Ansible logging directory for current project
install -m 0750 -d ./.ansible/logs

#! /usr/bin/env bash
set -euo pipefail

# deactivate Python virtualenv
deactivate

# remove Python virtualenv directory
rm -rf ./.ansible_venv/

# ensure Ansible directory completely removed
rm -rf ~/.ansible/

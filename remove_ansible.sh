#! /usr/bin/env bash
set -euo pipefail

# remove Python virtualenv directory
rm -rf ./.ansible_venv/

# ensure Ansible directory completely removed
rm -rf ~/.ansible/

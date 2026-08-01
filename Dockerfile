FROM registry.access.redhat.com/ubi9/ubi

ENV APP=ansible
ENV APP_HOME=/opt

ENV VENV_DIR=/opt/venv

ARG PYTHON_VERSION

# update and install necessary tools
RUN dnf update -y && \
  dnf install -y \
    python${PYTHON_VERSION} python${PYTHON_VERSION}-pip \
    unzip \
    wget \
    which && \
  dnf clean all

# AWS CLI v2
RUN wget -O awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip && \
    unzip awscliv2.zip && \
    ./aws/install --bin-dir /usr/bin --install-dir /usr/local/aws-cli --update && \
    rm -fr \
      awscliv2.zip \
      aws

# Set working directory where project will live
WORKDIR ${APP_HOME}/${APP}

# Copy requirements first for caching
COPY requirements.txt requirements.yml ./

# create python virtualenv
RUN python${PYTHON_VERSION} -m venv ${VENV_DIR}

# ensure python virtualenv is in PATH
ENV PATH=${VENV_DIR}/bin:${PATH}

# install required packages
RUN python3 -m pip install --upgrade pip && \
  pip install -r requirements.txt && \
  ansible-galaxy collection install -r requirements.yml && \
  # add Ansible logging directory for current project
  install -o root -g root -m 0750 -d ./.ansible/logs && \
  install -o root -g root -m 0640 /dev/null ./.ansible/logs/ansible.log

COPY . .

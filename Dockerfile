FROM ubuntu:22.04

# https://github.com/hashicorp/terraform/releases
ARG TERRAFORM_VERSION=1.13.3

# Install packages available through apt
RUN apt-get update && apt-get install -y \
  bash-completion \
  curl \
  git \
  unzip \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Terraform as root user
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform.zip \
  && unzip /tmp/terraform.zip -d /tmp \
  && mv /tmp/terraform /usr/local/bin/ \
  && rm -rf /tmp/* \
  && terraform version

# Create a non-root user named 'ubuntu'
RUN useradd -ms /bin/bash ubuntu && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to non-root user
USER ubuntu
WORKDIR /terraform

# Install auto-completions for non-root user
RUN terraform -install-autocomplete
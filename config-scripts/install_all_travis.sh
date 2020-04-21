#!/bin/bash
set -e

#Install ansible-lint
pip install --user ansible-lint

#Install Terraform
curl -O https://releases.hashicorp.com/terraform/0.12.24/terraform_0.12.24_linux_amd64.zip
sudo unzip terraform_0.12.24_linux_amd64.zip -d /usr/local/bin
terraform --version

# install tflint
curl https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# curl -L "$(curl -Ls https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" -o tflint.zip && unzip tflint.zip && rm tflint.zip

# Install ansible
sudo apt-get update
sudo apt-get install ansible -y

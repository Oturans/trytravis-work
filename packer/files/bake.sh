#!/bin/bash
set -e

# Install Puma
apt update
curl -o /etc/systemd/system/puma.service https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_infra/packer-base/packer/files/puma.service
sudo systemctl enable puma.service
systemctl start puma.service

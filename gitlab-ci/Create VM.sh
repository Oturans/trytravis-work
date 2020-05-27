#!/bin/bash
set -e

docker-machine create --driver google \
     --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
     --google-machine-type n1-standard-1\
     --google-zone europe-west1-b \
     --google-project docker-275905 \
     --google-disk-size 100 \
     --google-disk-type pd-ssd \
     --google-open-port 22/tcp \
     --google-open-port 80/tcp \
     --google-open-port 443/tcp \
     docker-host-ci

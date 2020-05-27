#!/bin/bash
set -ex

# Задаем переменные для gitlab-runner
docker_machine=docker-host-ci
gitlab_runner_name=<you-gitlab-runner-name>
gitlab_token=<you-gitlab-token>
gitlab_ip=<you-gitlab-ip>   ## gitlab_ip=$(docker-machine ip $docker_machine)

## ПОдымаем конктенер с нужным нам ранером 
docker-machine ssh $docker_machine \
"sudo docker run -d --name $gitlab_runner_name --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest"

## Регистрируем gitlab-runner 
docker-machine ssh $docker_machine \
" sudo docker exec -it $gitlab_runner_name gitlab-runner register  \
 --non-interactive \
  --executor "docker" \
  --docker-image alpine:latest \
  --url "http://$gitlab_ip/" \
  --registration-token "$gitlab_token" \
  --description "--docker-runner--" \
  --tag-list "linux,xenial,ubuntu,docker" \
  --run-untagged="true" \
  --locked="false" \
  --access-level="not_protected" \
  --docker-privileged \       
  --docker-volumes "/certs/client" "

# Oturans_microservices
Oturans microservices repository

[![Build Status](https://travis-ci.com/Otus-DevOps-2020-02/Oturans_microservices.svg?branch=master)](https://travis-ci.com/Otus-DevOps-2020-02/Oturans_microservices)


## Docker-2

1. Установили docker на рабочую среду.
2. Рассмотрели работу команд:
    **docker create** - создание контейнера без запуска.  
    **docker run**  - запускает контейнер  (docker run -it ubuntu:16.04 /bin/bash).  
    **docker ps -а**  - смотрим список всех контейнеров.  
    **docker images**  - список всех образов на рабочей среде.  
    **docker start**  - старт ранее запущенного контейнера.  
    **docker attach** - подключиться терминалом к уже запущенному контейнеру.  
    **docker kill** - убить контейнер =).  
    **docker system df** - занятое место.  
    **docker rm** - Удаление контейнера (-f работающего контейнера).  
    **docker rmi** - удаление образа.  
    **docker exec** - запуск приложения внутри запущенного контейнера (docker exec -it <u_container_id> bash).  
    **docker commit**  - создание образа из контейнера (docker commit <u_container_id> yourname/ubuntu-tmp-file).  
    **docker inspect** - побробная инфорамция о контейнере/образе (docker inspect <u_container_id>).  
3. **Задание со \*** docker inspect - описание в файле **docker-monolith/docker-1.log**
4. Создали новый проект в GCP  и настроили авторизацию в gcloud с json
5. Расмотрели работу с **docker-machine**  
   Подняли в gcp - **docker-host**
   ```
    docker-machine create --driver google \
        --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
        --google-machine-type g1-small\
        --google-zone europe-west1-b \
        --google-project docker-275905 \
        docker-host
   ```
   **eval $(docker-machine env docker-host)** - переключение на созданную виртуальную машину в gcp  
   **eval $(docker-machine env --unset)** - переключения на рабочую машину
6. **И сравните сами вывод:**

    ```
    docker run --rm -ti tehbilly/htop
    docker run --rm --pid host -ti tehbilly/htop
    ```

    Первая команда запускает докер контейнер как обычно, т.е. в отдельном namespases (только процессы внутри контейнера), вторая же запускает контейнер в namespaces хостовой машины (все процессы в том числе хостовой машины).

### Dockerfile

7. В репозитори создали папку **docker-monolith**  
    В папке 3 файла следующего содержимого
    **Dockerfile**

    ```
    FROM ubuntu:16.04

    RUN apt-get update && \
        apt-get install -y mongodb-server ruby-full ruby-dev build-essential git && \
        gem install bundler && \
        git clone -b monolith https://github.com/express42/reddit.git

    COPY mongod.conf /etc/mongod.conf
    COPY db_config /reddit/db_config
    COPY start.sh /start.sh

    RUN cd /reddit && bundle install && \
        chmod 0777 /start.sh

    CMD ["/start.sh"]
    ```

    [**mongod.conf**][1]
    [**db_config**][2]
    [**start.sh**][3]

8. Собираем образ из Dockerfile
    (**docker build -t reddit:latest .**)
9. Подымаем собранный образ (**docker run --name reddit -d --network=host reddit:latest**) в нашем **docker-host**, и видим что забыли Firewall,
    донастраиваем
    ```
    gcloud compute firewall-rules create reddit-app \
        --allow tcp:9292 \
        --target-tags=docker-machine \
        --description="Allow PUMA connections" \
        --direction=INGRESS
    ```
    В Итоге можно проверить результат тут: http://34.77.253.152:9292/

10. Регистрируемся на Docker hub и авторизуемся в консоли (**docker login**)
11. Делаем собственный образ из только что собранного (**docker tag reddit:latest oturans/otus-reddit:1.0**)
и загружаем его в docker hub (**docker push oturans/otus-reddit:1.0**)

    Запуск созданного контейнера (docker run --name reddit -d -p 9292:9292 oturans/otus-reddit:1.0)

12. **Задание со \***
    все собрано в папке **/docker-monolith/infra/**

    * Шаблон пакера, который делает образ с уже установленным Docker:
    docker подымается через провиженер **ansible - docker_packer.yml**
        - **cd packer && packer build -var-file variables.json docker.json**
    * Поднятие инстансов с помощью Terraform, их количество задается переменной:
    Переменная **ncount** проект в **./terraform**.
    заполняем **terraform.tfvars** запускаем
        - **terraform init && terraform apply -auto-approve**
    * Несколько плейбуков Ansible с использованием динамического инвентори для установки докера и запуска там образа приложения:
    Проект в ./ansible
    DI настроено, можно посмотреть [inventory.gcp.yml][4]

        3 playbook:  
        [**docker_packer.yml**][5] - установка docker  
        [**docker_deploy.yml**][6] - поднятие oturans/otus-reddit:1.0 в docker  
        [**docker_main.yml**][7] - общий playbook накатывающий оба предыдущих  

        запуск **ansible-playbook docker_main.yml --limit docker_machine**

[1]: https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_microservices/docker-2/docker-monolith/mongod.conf
[2]: https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_microservices/docker-2/docker-monolith/db_config
[3]: https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_microservices/docker-2/docker-monolith/start.sh
[4]: https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_microservices/docker-2/docker-monolith/infra/ansible/inventory.gcp.yml
[5]: https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_microservices/docker-2/docker-monolith/infra/ansible/docker_packer.yml
[6]: https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_microservices/docker-2/docker-monolith/infra/ansible/docker_deploy.yml
[7]: https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_microservices/docker-2/docker-monolith/infra/ansible/docker_main.yml

## Docker-3

1. Создан каталог src в него скопировано наше приложение.  
2. Собраны 3 образа  
    oturans/post:1.0  (./post/Dockerfile)  
    oturans/comment:1.0 (./comment/Dockerfile)  
    oturans/ui:1.0  (./ui/Dockerfile)  

    ```
    docker build -t oturans/post:1.0 ./post-py
    docker build -t oturans/comment:1.0 ./comment
    docker build -t oturans/ui:1.0 ./ui
    ```

3. Создали bridge-сеть reddit  
   ```
   docker network create reddit
   ```

4. **Задание со \*** запуск с другими сетевыми алиасами, без пересборки  
    ```
    docker run -d --network=reddit \
        --network-alias=post_db_test \
        --network-alias=comment_db_test \
        -v reddit_db:/data/db mongo:latest

    docker run -d --network=reddit \
        --env POST_DATABASE=posts_test \
        --env POST_DATABASE_HOST=post_db_test \
        --network-alias=posts_test oturans/post:1.0

    docker run -d --network=reddit \
        --env COMMENT_DATABASE=comments_test \
        --env COMMENT_DATABASE_HOST=comment_db_test \
        --network-alias=comments_test oturans/comment:1.0

    docker run -d --network=reddit \
        --env POST_SERVICE_HOST=posts_test \
        --env COMMENT_SERVICE_HOST=comments_test \
        -p 9292:9292 oturans/ui:5.0
    ```
5. **Задание со \*** Пересборка ui образа на alpine  
    Пересобрали можно посмотреть [Dockerfile][8] итоговый образ залит на [Docker HUB][9]  
6. Создали volume и подключили к образу  
    ```
    docker volume create reddit_db
    docker run -d --network=reddit \
        --network-alias=post_db_test \
        --network-alias=comment_db_test \
        -v reddit_db:/data/db mongo:latest
    ```

[8]: https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_microservices/docker-3/src/ui/Dockerfile.1
[9]: https://hub.docker.com/repository/docker/oturans/ui


## Docker-4

#### Host network

1. Сравним вывод команд:  
```
> docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig

> docker-machine ssh docker-host ifconfig
```

В результате получим одинаковую картину, так как контейнер запускается ***--network host***.

2. Запустите несколько раз (2-4)
```
> docker run --network host -d nginx
``` 
Видим что при каждом новом запуске старый ранее запущенный контейнер останавливается, и запускается новый. 
Причина - Цитата из лекции: **Два сервиса в разных контейнерах не могут слушать один и тот же порт**

#### Bridge network

3. Создали сеть 
   ```
   docker network create reddit --driver bridge
   ```
4. Запустили наше приложение с указанием алиасов  
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest 
docker run -d --network=reddit --network-alias=post oturans/post:1.0
docker run -d --network=reddit --network-alias=comment oturans/comment:1.0   
docker run -d --network=reddit -p 9292:9292 oturans/ui:5.0
```
5. Для случая когда у нас один контейнер должен быть подключен к разным сетям, то необходимо после запуска контейнера подключить его к нужной сети
   ```
        Создаем сети
    docker network create back_net --subnet=10.0.2.0/24
    docker network create front_net --subnet=10.0.1.0/24
        Подымаем контейнеры
    docker run -d --network=back_net --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest  
    docker run -d --network=back_net --network-alias=post oturans/post:1.0
    docker run -d --network=back_net --network-alias=comment oturans/comment:1.0  && \
    docker run -d --network=front_net -p 9292:9292 oturans/ui:5.0
        Добавляем нужным контейнерам, нужные сети
    docker network connect front_net post
    docker network connect front_net comment
   ```

#### Docker-compose

6. Подымаем наши конктейнеры с помошью Docker-compose, Предварительно настроив [**docker-compose.yml**][10] и переменные окружения [**.env.example**][11]
    ```
    docker-compose up -d
    ```

7. Базовое имя проекта формируется из
"Директория в которой лежит docker-compose" 
С помошью директривы '-p' можно указать/изменить имя проекта или же использовать переменную COMPOSE_PROJECT_NAME

```
docker-compose -p test up -d --build

COMPOSE_PROJECT_NAME=test
```

8. **Задание со \*** 

Настроен [**docker-compose.override.yml**][12]

Для запуска проект выполянем:

```
docker-machine scp -r post-py/ docker-host:/home/docker-user/post-py  

docker-machine scp -r comment/ docker-host:/home/docker-user/comment

docker-machine scp -r UI/ docker-host:/home/docker-user/ui

docker-compose up -d
```
[10]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_microservices/docker-4/src/docker-compose.yml
[11]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_microservices/docker-4/src/.env.example
[12]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_microservices/docker-4/src/docker-compose.override.yml


## Gitlab-ci-1

1. Создали сервер для работы с Gitlab-CI посредством docker-machine  

```
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
```

2. Подготовили ВМ для запуска Gitlab-ci  

```
docker-machine ssh docker-host-ci "sudo mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs"

```

3. Создаем в репозитории ./gitlab-ci файл [**docker-compose.yml**][13], где в путь external_url подcтавляем ip выданный **docker-machine ip docker-host-ci**  
4. Подняли контейнер Gitlab-ci посредством **docker-compose up -d** предварительно настроив среду **eval $(docker-machine env docker-host-ci)**
5. Создали проект, настроили piplines [**.gitlab-ci.yml**][14]  
6. Подключили внешний репозиторий к проекту **git remote add gitlab http://$(docker-machine ip docker-host-ci)/homework/example.git**  
7. Подняли Gitlab-runner так же в docker контейнере и зарегистрировали  

```
docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest

docker exec -it gitlab-runner gitlab-runner register  \
 --non-interactive \
  --executor "docker" \
  --docker-image alpine:latest \
  --url "http://<your-vm-ip>/" \
  --registration-token "<your-token-in-project> \
  --description "--docker-runner--" \
  --tag-list "linux,xenial,ubuntu,docker" \
  --run-untagged="true" \
  --locked="false" \
  --access-level="not_protected" \
  --docker-privileged \       ####<----------------------важные пункты без этого DIND работать не будет!!!
  --docker-volumes "/certs/client" ####<-----------------важные пункты без этого DIND работать не будет!!!
```

8. Сделали коммиты проверили что все работает   
9. **Задание со \*** В блок Build добавлена сборка контейнера с приложением reddit и его загрузку в docker hub  
    https://hub.docker.com/repository/docker/oturans/reddit/general  


```
services:
    - docker:19.03-dind
  
build_job:
    stage: build 
    image: docker:19.03
    before_script:
      - docker info
      - docker login -u $LOGIN_DH -p $PASSWORD_DH

    script:
      - echo 'Building'
      - cd $CI_PROJECT_DIR/docker-monolith
      - docker build -t oturans/reddit:$CI_COMMIT_SHORT_SHA .
      - docker push $LOGIN_DH/reddit:$CI_COMMIT_SHORT_SHA
```
Для работы в последних images docker необходимо регистрировать gitlab runner c ключами:

  ```
  --docker-privileged
  --docker-volumes "/certs/client"
  ```

Далее посредством посдетсовм того же docker-machine можно настроить разворачивание, аналогично тому как мы создали машину для работы по ДЗ.  

Переменные **$LOGIN_DH $PASSWORD_DH** заданы через **variables**  

10.   **Задание со \*** Вариант разворачивания Gitlab-runner через bash и docker-machine [**Gitlab-Runner-install.sh**][15]  
11.   **Задание со \***  Настроена интеграция Gitlab - Slack канал:  
      #andrey_protasovitskiy  
Ссылка: https://devops-team-otus.slack.com/archives/CVA8AQ5RV  


[13]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_microservices/gitlab-ci-1/gitlab-ci/docker-compose.yml
[14]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_microservices/gitlab-ci-1/.gitlab-ci.yml
[15]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_microservices/gitlab-ci-1/gitlab-ci/Gitlab-Runner-install.sh

## Monitoring-1

1. Создаем ВМ
```
docker-machine create --driver google \
     --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
     --google-machine-type n1-standard-1\
     --google-zone europe-west1-b \
     --google-project docker-275905 \
     --google-disk-size 20 \
     --google-disk-type pd-ssd \
     --google-open-port 9292/tcp \
     --google-open-port 9090/tcp 
     docker-host
```

2. Настроили сборку Docker образа Prometheus с нужным нам конфигом [./monitoring/prometheus/prometheus.yml][16]
   ```
    FROM prom/prometheus:v2.1.0
    ADD prometheus.yml /etc/prometheus/
   ```

3. Настроили docker-compose для разворачивания нашего приложения + мониторинг [./docker/docker-compose.yml][17]
4. Запушили все образы в Docker HUB 
   https://hub.docker.com/u/oturans  
5. **Задание со \*** В мониторинг добавлено использование **percona_mongodb_exporter**  
   [./monitoring/prometheus/prometheus.yml:][16]  
   ```
    ...
      - job_name: 'percona_mongodb_exporter'
        static_configs:
          - targets:
            - 'mongodb-exporter:9216'
    ...
   ```

   [./docker/docker-compose.yml:][17]  
   ```
    ...
    mongodb-exporter:
        image: bitnami/mongodb-exporter:0.11.0
        environment:
            - MONGODB_URI='mongodb://post_db:27017'
        networks:
            - back_net
    ...
   ```
6. **Задание со \*** В мониторинг добавлено использование **blackbox-exporter**  
   [./monitoring/prometheus/prometheus.yml:][16]  
   ```
   ...
    - job_name: blackbox
        metrics_path: /metrics
        static_configs:
            - targets:
                - blackbox-exporter:9115

    - job_name: blackbox_http
        metrics_path: /probe
        params:
            module: [http_2xx]
        static_configs:
            - targets:
                - http://ui:9292
                - http://comment:9292
                - http://post:5000

        relabel_configs:
          - source_labels: [__address__]
            target_label: __param_target
          - source_labels: [__param_target]
            target_label: instance
          - target_label: __address__
            replacement: blackbox-exporter:9115

      - job_name: 'blackbox_port_connect'
        metrics_path: /probe
        params:
            module: ['tcp_connect']
        static_configs:
            - targets:
                - ui:9292
                - comment:9292
                - post:5000
        relabel_configs:
          - source_labels: [__address__]
            target_label: __param_target
          - source_labels: [__param_target]
            target_label: instance
          - target_label: __address__
            replacement: blackbox-exporter:9115
   ...
   ```
   [./docker/docker-compose.yml:][17]  
   ```
   ...
    blackbox-exporter:
        image: ${USER_NAME}/blackbox
        ports:
            - '9115:9115'
        networks:
            - back_net
            - front_net
   ...
   ```
7. **Задание со \*** Настроен [**Makefile**][18]  
    - Билдим любой или все образы, которые сейчас используются  
    - Пушим  любой или все образы в докер хаб  
    - Подымаем или останавливаем наше приложение с мониторингом  
  P.S. Не забываем предварительно задать переменную  **export USER_NAME=<...>**  



[16]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_microservices/monitoring-1/monitoring/prometheus/prometheus.yml
[17]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_microservices/monitoring-1/docker/docker-compose.yml
[18]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_microservices/monitoring-1/Makefile

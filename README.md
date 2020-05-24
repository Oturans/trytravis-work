# Oturans_microservices
Oturans microservices repository

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
[10]:https:\\test.test
[11]:https:\\test.test
[12]:https:\\test.test

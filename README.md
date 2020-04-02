# Oturans_infra_repository

## Play-travis

1. Настроен шаблон PR по умолчанию для github (.github/PULL_REQUEST_TEMPLATE.md).
2. Настроены линтеры посредством pre-commit в частности:
    'trailing-whitespace'.
    'end-of-file-fixer'.
3. Настроена связь проекта с Travis CI, подключены уведомления в чат Slack.
4. Алгоритм сборки и тестирования пока не понятен.
5. Добавлен стандарный тест с ошибкой (play-travis/test.py).
6. Исправлена ошибка в тесте (play-travis/test.py)

## Cloud-bastion

1. на GCP поднято 2 машины
bastion - 10.132.0.9 / 35.210.169.182
someinternalhost - 10.13.0.8
1. Настроен доступ по SSH к указанным машинам 
   Доп задание подключиться к someinternalhost напрямую.
    На локальной машине создаем файлик ~/.ssh/config
    В него заносим:

Host bastion
  HostName     35.210.169.182
  User         appuser
  IdentityFile ~/.ssh/appuser
  ForwardAgent yes

Host someinternalhost
  HostName     10.132.0.8
  User         appuser
  ProxyJump    bastion

сохраняем, набираем ssh someinternalhost и мы попали в нужную ВМ.
2. На ВМ bastion установлен VPN сервер Pritunl
3.1. Подключено доменное имя посредством DNS(sslip.io) - 35-210-169-182.sslip.io
3.2. Настроен валидный сертификат.
3.3. В репозиторий сохранен файл конфигурации для OpenVPN (cloud-bastion.ovpn).

bastion_IP = 35.210.169.182
someinternalhost_IP = 10.132.0.8

## Cloud-Testapp

testapp_IP = 35.195.182.253
testapp_port = 9292

1. Создана ВМ на GCP 

gcloud compute instances create reddit-app \
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--zone europe-west1-d \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure

2. Установлен 
Ruby - install_ruby.sh
Monodb - install_mongodb.sh
Приложение  - deploy.sh

Можно проверить по порту 35.195.182.253:9292

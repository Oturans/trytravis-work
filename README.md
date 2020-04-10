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

testapp_IP = 35.187.42.51
testapp_port = 9292

1. Создана ВМ на GCP 

~~~~
gcloud compute instances create reddit-app \
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--zone europe-west1-d \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure
~~~~

2. Установлен 
Ruby - install_ruby.sh
Monodb - install_mongodb.sh
Приложение  - deploy.sh

Можно проверить по порту 35.187.42.51:9292

3. Составлен доп скрипт(startup-script.sh) для создания виртуальной машины и развертывая приложения.

Итоговая командна gcloud будет выглядеть:

~~~~
gcloud compute instances create reddit-app \
--boot-disk-size=10GB \
--image-family ubuntu-1604-lts \
--image-project=ubuntu-os-cloud \
--zone europe-west1-d \
--machine-type=g1-small \
--tags puma-server \
--restart-on-failure \
--metadata=startup-script=\#\!/bin/bash$'\n'apt\ update$'\n'apt\ install\ -y\ ruby-full\ ruby-bundler\ build-essential$'\n'apt-key\ adv\ --keyserver\ hkp://keyserver.ubuntu.com:80\ --recv-keys\ 0xd68fa50fea312927$'\n'bash\ -c\ \'echo\ \"deb\ http://repo.mongodb.org/apt/ubuntu\ xenial/mongodb-org/3.2\ multiverse\"\ \>\ /etc/apt/sources.list.d/mongodb-org-3.2.list\'$'\n'apt\ update$'\n'apt\ install\ -y\ mongodb-org\ $'\n'systemctl\ start\ mongod$'\n'systemctl\ enable\ mongod$'\n'git\ clone\ -b\ monolith\ https://github.com/express42/reddit.git$'\n'cd\ reddit\ \&\&\ bundle\ install$'\n'puma\ -d
~~~~

4. Создание правила фаервола через gcloud 

~~~~
gcloud compute --project=infra-270920 firewall-rules create default-puma-server --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:9292 --source-ranges=0.0.0.0/0 --target-tags=puma-server
~~~~

## Packer

1. Настроена сборка образов в GCP  
**reddit-base** - [packer/ubuntu16.json][1]    - только неизменяемая среда  
**reddit-full** - [packer/immutable.json][2]   - Среда + само приложение  
Пример заполнения variables - [packer/variables.json.example][3]  


[1]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_infra/packer-base/packer/ubuntu16.json
[2]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_infra/packer-base/packer/immutable.json
[3]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_infra/packer-base/packer/variables.json.example

2. Для сборки:  
**reddit-base** использован базовый образ ubuntu_1604 и скрипты:  
    [packer/scripts/install_mongodb.sh][4]  
    [packer/scripts/install_ruby.sh][5]  

[4]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_infra/packer-base/packer/scripts/install_mongodb.sh
[5]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_infra/packer-base/packer/scripts/install_ruby.sh

**reddit-full** использован образ reddit-base  
    скрипт [packer/files/bake.sh][6]  
    файл конфигуарции службы puma: [packer/files/puma.service][7] (настроен автозапуск)  

[6]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_infra/packer-base/packer/files/bake.sh
[7]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_infra/packer-base/packer/files/puma.service

3. Для запуска виртуальной машины составлен скрипт gcloud  
[config-scripts/create-reddit-vm.sh][8]  

[8]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_infra/packer-base/config-scripts/create-reddit-vm.sh


## Terraform - 1

1. Изучили работу команд  
       terraform plan  
       terraform apply  
       terraform show  
       terraform refresh  
       terraform destroy  
       terraform output  
       terraform taint  
       terraform fmt  

2. Создаем виртуальную машину на базе образа "reddit-base" задаем инстанс в котором устанавливаем наше приложение reddit-app посредством использования provisioner - [main.tf][9]  

3. Создаем правило фаервола для нашего приложения. 
```
resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"
  # Название сети, в которой действует правило
  network = "default"
  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]
  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-app"]
}
```
4. Добавляем **SSH-KEY** в наш проект(appuser,appuser1,appuser2) 
```
 metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}appuser1:${file(var.public_key_path)}appuser2:${file(var.public_key_path)}"
  }
```
[9]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_infra/terraform-1/terraform/main.tf
5. Input переменные вынесены в файл, пример в файле [terraform.tfvars.example][10]  

[10]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_infra/terraform-1/terraform/terraform.tfvars.example
6. Output переменные вынесены в файл [outputs.tf][11]  

[11]:https://raw.githubusercontent.com/Otus-DevOps-2020-02/Oturans_infra/terraform-1/terraform/outputs.tf    
7. В рамках cамостоятельной работы:   
      7.1. Определили input переменную для приватного ключа  
      7.2. Определили input переменную для зоны, так же она обладает значением по умолчанию  
      7.3. Воспользовались командой terraform fmt.  
      7.4. Пример заполнения [terraform.tfvars.example][10]  
8. Задание *(52 слайд)-несколько ключей в проект - ключи добавлены как один так и несколько ключей - [main.tf][9]  
9. Задание *(53 слайд) - терраформ удаляет ключи которые не описаны в нем, что в общем то логично, он привеодит проект к тому виду который мы задали и с теми ключами корые задали пунктом выше. Пока проблемы не вижу, скорее всего нет опыта   
10. Задание **(54 слайд) - балансировщик не настроил, не разобрался с особенностью его работы в GCP   
11. Задание **(55 слайд) - не выполнил, копипаст. копипаст сложнее сопровождать, человеческий фактор      
12. задание **(56 слайд) - Выполнил добавил count [main.tf][9]  

## Terraform - 2

1. Создали правило Firewall, для решения кофликта что правило уже создано, было импортировано правило в stage
 - terraform import google_compute_firewall.firewall_ssh default-allow-ssh  
2. На практических примерах расмотрели как влияет очередность создания ресурсов, от внутренних зависимостей одного от другого. 





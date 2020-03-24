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
2. Настроен доступ по SSH к указанным машинам (пункт с прокидыванием пока не разобрался).
3. На ВМ bastion установлен VPN сервер Pritunl
3.1. Подключено доменное имя посредством DNS(sslip.io) - 35-210-169-182.sslip.io
3.2. Настроен валидный сертификат.
3.3. В репозиторий сохранен файл конфигурации для OpenVPN (cloud-bastion.ovpn).

bastion_IP = 35.210.169.182
someinternalhost_IP = 10.132.0.8

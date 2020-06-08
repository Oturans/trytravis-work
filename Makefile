USER_NAME = oturans

#---------------------------------------------------system

ip:
	docker-machine ip docker-host
ssh:
	docker-machine ssh docker-host

#---------------------------------------------------docker-machine

docker-start:
	export USER_NAME=oturans
	docker-machine start docker-host
	docker-machine regenerate-certs docker-host -f
	docker-machine ip docker-host
	
docker-eval:
	eval $(docker-machine env docker-host)
	docker ps -a

docker-stop:
	docker-machine stop docker-host
	eval $(docker-machine env -u)

#---------------------------------------------------START

start: start-mon start-prog 

start-mon: build-mon
	export USER_NAME=${USER_NAME}
	cd ./docker && docker-compose -f docker-compose-monitoring.yml up -d

start-prog: build-prog
	export USER_NAME=${USER_NAME}
	cd ./docker && docker-compose up -d 

#---------------------------------------------------STOP

stop: stop-prog stop-mon 

stop-prog: 
	cd ./docker && docker-compose down 
stop-mon:
	cd ./docker && docker-compose -f docker-compose-monitoring.yml down

#---------------------------------------------------BUILD

build-all: build-prog build-mon
build-prog: build-ui build-comment build-post
build-mon: build-prometheus build-blackbox build-alertmanager build-telegraf build-grafana build-trickster

build-ui:
	cd ./src/ui && bash ./docker_build.sh

build-comment:
	cd ./src/comment && bash ./docker_build.sh

build-post:
	cd ./src/post-py && bash ./docker_build.sh

build-blackbox:
	cd ./monitoring/blackbox && docker build -t ${USER_NAME}/blackbox .

build-prometheus:
	cd ./monitoring/prometheus && docker build -t ${USER_NAME}/prometheus .

build-alertmanager:
	cd ./monitoring/alertmanager && docker build -t ${USER_NAME}/alertmanager .

build-telegraf:
	cd ./monitoring/telegraf && docker build -t ${USER_NAME}/telegraf .

build-grafana:
	cd ./monitoring/grafana && docker build -t ${USER_NAME}/grafana .

build-trickster:
	cd ./monitoring/trickster && docker build -t ${USER_NAME}/trickster .

#---------------------------------------------------PUSH

push-all: push-ui push-comment push-post push-blackbox push-prometheus push-alertmanager push-telegraf push-trickster

push-ui:
	docker push ${USER_NAME}/ui

push-comment:
	docker push ${USER_NAME}/comment

push-post:
	docker push ${USER_NAME}/post

push-blackbox:
	docker push ${USER_NAME}/blackbox

push-prometheus:
	docker push ${USER_NAME}/prometheus

push-alertmanager:
	docker push ${USER_NAME}/alertmanager

push-telegraf:
	docker push ${USER_NAME}/telegraf

push-grafana:
	docker push ${USER_NAME}/grafana

push-trickster:
	docker push ${USER_NAME}/trickster

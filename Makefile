USER_NAME = oturans

#---------------------------------------------------system

ip-mon:
	docker-machine ip docker-host
ip-lpg:
	docker-machine ip docker-host
ssh-mon:
	docker-machine ssh docker-host
ssh-log:
	docker-machine ssh docker-host

#---------------------------------------------------docker-host

docker-start-docker-host:
	export USER_NAME=oturans
	docker-machine start docker-host
	docker-machine regenerate-certs docker-host -f
	docker-machine ip docker-host
	
docker-eval:
	eval $(docker-machine env docker-host)
	docker ps -a

docker-stop-docker-host:
	docker-machine stop docker-host
	eval $(docker-machine env -u)

#---------------------------------------------------logging

docker-start-logging:
	export USER_NAME=oturans
	docker-machine start logging
	docker-machine regenerate-certs logging -f
	docker-machine ip logging
	
docker-eval-log:
	eval $(docker-machine env logging)
	docker ps -a

docker-stop-logging:
	docker-machine stop logging
	eval $(docker-machine env -u)

#---------------------------------------------------START

start: start-log start-mon start-prog 
start-lp: start-log start-prog
start-mp: start-mon start-prog

start-mon: build-mon
	export USER_NAME=${USER_NAME}
	cd ./docker && docker-compose -f docker-compose-monitoring.yml up -d

start-prog: build-prog
	export USER_NAME=${USER_NAME}
	cd ./docker && docker-compose up -d 

start-log: build-log
	export USER_NAME=${USER_NAME}
	cd ./docker && docker-compose -f docker-compose-logging.yml up -d

#---------------------------------------------------STOP

stop: stop-prog stop-log stop-mon

stop-lp: stop-prog stop-log
stop-mp: stop-prog stop-mon

stop-prog: 
	cd ./docker && docker-compose down 
stop-mon:
	cd ./docker && docker-compose -f docker-compose-monitoring.yml down
stop-log:
	cd ./docker && docker-compose -f docker-compose-logging.yml down

#---------------------------------------------------BUILD

build-all: build-prog build-mon build-log
build-prog: build-ui build-comment build-post
build-mon: build-prometheus build-blackbox build-alertmanager build-telegraf build-grafana build-trickster
build-log: build-fluentd

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

build-fluentd:
	cd ./logging/fluentd && docker build -t ${USER_NAME}/fluentd .

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


push-fluentd:
	docker push ${USER_NAME}/fluentd

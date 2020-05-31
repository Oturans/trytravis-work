USER_NAME = oturans

start: build-all 
	cd ./docker && docker-compose up -d

stop: 
	cd ./docker && docker-compose down

build-all: build-ui build-comment build-post build-prometheus build-blackbox

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

push-all: push-ui push-comment push-post push-blackbox push-prometheus

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

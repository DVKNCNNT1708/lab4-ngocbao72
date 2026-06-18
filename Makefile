IMAGE_NAME ?= fit4110/iot-ingestion:lab04
CONTAINER_NAME ?= fit4110-iot-lab04
PORT ?= 8000
TEAM_IMAGE_NAME ?= ghcr.io/ngocbao72/team-iot:v0.1.0-team-iot

install:
	npm install

lint:
	npm run lint:openapi

mock:
	npm run mock:team-iot

test-mock:
	npm run test:team-iot:mock

build:
	docker build -t $(IMAGE_NAME) .
	docker tag $(IMAGE_NAME) $(TEAM_IMAGE_NAME)

run:
	docker run --rm --name $(CONTAINER_NAME) -p $(PORT):8000 --env-file .env.example $(IMAGE_NAME)

run-detached:
	docker run -d --rm --name $(CONTAINER_NAME) -p $(PORT):8000 --env-file .env.example $(IMAGE_NAME)

health:
	curl http://localhost:$(PORT)/health

test-docker:
	npm run test:team-iot:local

stop:
	docker stop $(CONTAINER_NAME) || true

clean-reports:
	rm -f reports/*.xml reports/*.html reports/*.json

tag ?= ghcr.io/becojo/ctf-challenges/the-great-processor:latest
annotations ?= org.opencontainers.image.source=https://github.com/becojo/ctf-challenges

up:
	docker compose up -d
	@echo "Connect to the challenge using netcat:"
	@echo "nc 127.0.0.1 54098"

down:
	docker compose down

docker.build:
	docker build -t $(tag) .

docker.push:
	docker buildx build --push --annotation $(annotations) --platform linux/amd64,linux/arm64 -t $(tag) .

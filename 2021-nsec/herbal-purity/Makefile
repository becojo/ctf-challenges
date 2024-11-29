tag ?= ghcr.io/becojo/ctf-challenges/herbal-purity:latest
annotations ?= org.opencontainers.image.source=https://github.com/becojo/ctf-challenges

up:
	docker compose up -d
	@echo "Visit http://127.0.0.1:45546/index.html"

down:
	docker compose down

docker.build:
	docker build -t $(tag) .

docker.push:
	docker buildx build --push --annotation $(annotations) --platform linux/amd64,linux/arm64 -t $(tag) .

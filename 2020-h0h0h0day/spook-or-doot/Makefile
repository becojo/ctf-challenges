tag ?= ghcr.io/becojo/ctf-challenges/spook-or-doot:latest

up:
	docker compose up -d
	@echo "Visit http://127.0.0.1:23292"

down:
	docker compose down

docker.push:
	docker buildx build --push --platform linux/amd64,linux/arm64 -t $(tag) .

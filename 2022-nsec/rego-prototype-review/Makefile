tag ?= ghcr.io/becojo/ctf-challenges/rego-prototype-review:latest

up:
	docker compose up -d
	@echo "Connect to the challenge using netcat:"
	@echo "nc 127.0.0.1 41640"

down:
	docker compose down

docker.push:
	docker buildx build --push --platform linux/amd64,linux/arm64 -t $(tag) .

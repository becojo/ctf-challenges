tag ?= ghcr.io/becojo/ctf-challenges/truncator:latest

up:
	docker compose up -d
	@echo "Visit http://localhost:36087"

down:
	docker compose down

docker.build:
	docker build -t $(tag) .

docker.push:
	docker buildx build --push --platform linux/amd64,linux/arm64 -t $(tag) .

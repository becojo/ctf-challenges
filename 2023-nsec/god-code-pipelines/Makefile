tag ?= ghcr.io/becojo/ctf-challenges/god-code-pipelines:latest
annotations ?= org.opencontainers.image.source=https://github.com/becojo/ctf-challenges

up:
	docker compose up -d
	@echo "Start the challenge by cloning the repositories"
	@echo "Note: Make sure to create a branch before pushing changes"
	@echo
	@echo "git clone ssh://git@127.0.0.1:54090/prettier"
	@echo "git clone ssh://git@127.0.0.1:54091/semgrep"
	@echo "git clone ssh://git@127.0.0.1:54092/gomplate"
	@echo
	@echo "Password: git"

down:
	docker compose down

docker.build:
	docker compose build

docker.push:
	docker buildx build --target semgrep --push --annotation $(annotations) --platform linux/amd64 -t $(tag)-semgrep .
	docker buildx build --target gomplate --push --annotation $(annotations) --platform linux/amd64,linux/arm64 -t $(tag)-gomplate .
	docker buildx build --target prettier --push --annotation $(annotations) --platform linux/amd64,linux/arm64 -t $(tag)-prettier .

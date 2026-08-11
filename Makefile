.DEFAULT_GOAL := help

NAME = [a-z0-9]+(-[a-z0-9]+)*
EVENT = [0-9]{4}-$(NAME)

help: ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "make %-6s # %s\n", $$1, $$2}'

lint: ## validate the year-event/challenge folder structure
	@err=0; \
	for f in *; do \
		[ -e "$$f" ] || continue; \
		case "$$f" in \
			README.md|Makefile|LICENSE|.git|.github|.gitignore) continue;; \
		esac; \
		if ! printf '%s' "$$f" | grep -Eq '^$(EVENT)$$'; then \
			echo "LINT: unexpected top-level entry: $$f"; err=1; \
			continue; \
		fi; \
		if [ ! -d "$$f" ]; then \
			echo "LINT: not a directory: $$f"; err=1; \
			continue; \
		fi; \
		n=0; \
		for c in "$$f"/*; do \
			[ -e "$$c" ] || continue; \
			n=$$((n+1)); \
			cb="$${c%/}"; cb="$${cb##*/}"; \
			if ! printf '%s' "$$cb" | grep -Eq '^$(NAME)$$'; then \
				echo "LINT: unexpected entry in $$f/: $$cb"; err=1; \
			elif [ ! -d "$$c" ]; then \
				echo "LINT: not a directory: $$f/$$cb"; err=1; \
			elif [ -z "$$(ls -A "$$c")" ]; then \
				echo "LINT: empty challenge dir: $$f/$$cb"; err=1; \
			fi; \
		done; \
		if [ "$$n" -eq 0 ]; then \
			echo "LINT: no challenges in $$f/"; err=1; \
		fi; \
	done; \
	if [ "$$err" -eq 0 ]; then \
		echo "lint: OK"; \
	else \
		echo "lint: FAILED"; exit 1; \
	fi

year ?= $(shell date +%Y)
event ?=
challenge ?=

new: ## scaffold a new challenge: make new event=EVENT challenge=CHALLENGE [year=YYYY]
	@[ -n "$(event)" ] || { echo "usage: make new event=EVENT challenge=CHALLENGE [year=$(year)]"; exit 1; }; \
	[ -n "$(challenge)" ] || { echo "usage: make new event=EVENT challenge=CHALLENGE [year=$(year)]"; exit 1; }; \
	printf '%s' "$(year)"     | grep -Eq '^[0-9]{4}$$' || { echo "error: year '$(year)' must be 4 digits"; exit 1; }; \
	printf '%s' "$(event)"    | grep -Eq '^$(NAME)$$' || { echo "error: event '$(event)' must match $(NAME)"; exit 1; }; \
	printf '%s' "$(challenge)" | grep -Eq '^$(NAME)$$' || { echo "error: challenge '$(challenge)' must match $(NAME)"; exit 1; }; \
	dir="$(year)-$(event)/$(challenge)"; \
	if [ -e "$$dir" ]; then \
		echo "error: $$dir already exists"; exit 1; \
	fi; \
	base="$${dir%/*}"; \
	mkdir -p "$$base"; \
	mkdir "$$dir" || { echo "error: $$dir already exists"; exit 1; }; \
	printf '# %s\n\nTODO: describe the challenge\n' "$(challenge)" > "$$dir/README.md"; \
	printf 'tag ?= ghcr.io/becojo/ctf-challenges/%s:latest\n\nup:\n\tdocker compose up -d\n\ndown:\n\tdocker compose down\n\ndocker.push:\n\tdocker buildx build --push --platform linux/amd64,linux/arm64 -t $$(tag) .\n' "$(challenge)" > "$$dir/Makefile"; \
	echo "created $$dir/"

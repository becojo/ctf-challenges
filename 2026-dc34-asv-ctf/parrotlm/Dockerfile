FROM ghcr.io/astral-sh/uv:python3.14-alpine AS builder

WORKDIR /app

# install dependencies from cache & skip large unused packages
COPY src/pyproject.toml src/uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv uv sync --no-dev --frozen \
  --no-install-package pyarrow \
  --no-install-package pygments \
  --no-install-package alembic \
  --no-install-package sqlalchemy \
  --no-install-package opentelemetry \
  --no-install-package huggingface_hub \
  --no-install-package grpc \
  --no-install-package aiosqlite

# make sure uv won't try to install missing packages
ENV UV_NO_SYNC=1

COPY src ./

EXPOSE 8080
ENTRYPOINT ["uv", "run"]
CMD ["main.py"]

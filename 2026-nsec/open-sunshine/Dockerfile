ARG BASE_IMAGE=debian:bookworm-slim

# Builder stage for pyodide
FROM ${BASE_IMAGE} AS builder

RUN apt-get update && apt-get install -y wget bzip2 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/pyodide && \
    cd /tmp/pyodide && \
    wget https://github.com/pyodide/pyodide/releases/download/0.28.2/pyodide-core-0.28.2.tar.bz2 && \
    tar -xjf pyodide-core-0.28.2.tar.bz2

# Final stage
FROM ${BASE_IMAGE} AS bun

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    bzip2 \
    curl \
    bash \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Install bun
RUN curl -fsSL https://bun.sh/install | bash && mv /root/.bun/bin/bun /usr/bin/bun

FROM bun AS bundle

COPY src /app
WORKDIR /app

RUN bun install --frozen-lockfile

RUN mkdir -p /app/challenge && \
    bun build ./index.ts --target bun --outfile /app/challenge/server.js

FROM bun

# Copy pyodide from builder
COPY --from=builder /tmp/pyodide/pyodide /usr/local/pyodide

# Create users
RUN useradd -m -s /bin/sh part1 && \
    useradd -m -s /bin/sh part2

# Create flag files
RUN echo "FLAG-$(openssl rand -hex 16)" > /flag-part1-588a73f4f35de2854100635ea9416645dd477a9c.txt && \
    echo "FLAG-$(openssl rand -hex 16)" > /flag-part2-588a73f4f35de2854100635ea9416645dd477a9c.txt && \
    chown root:part1 /flag-part1-*.txt && \
    chown root:part2 /flag-part2-*.txt && \
    chmod 0440 /flag-*.txt

# Copy bundled app and entrypoint from bundle stage
COPY --from=bundle /app/challenge/server.js /server.js
COPY src/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set environment variables
ENV PYODIDE_DIR=/usr/local/pyodide
ENV LISTEN=0.0.0.0
ENV PART2_WAF=1

# Expose ports
EXPOSE 80 8080

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]

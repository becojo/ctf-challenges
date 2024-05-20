ARG BUN=oven/bun:latest@sha256:2b283192796dfa02fc2f0f9f3749b4f64ef53bc0a4c7006f3816b7011bcecb0e

FROM ${BUN} as build

COPY ./app /app
WORKDIR /app

RUN bun install --production
RUN bun build --minify --target bun --outfile app.js index.tsx

FROM ${BUN} as vendor
WORKDIR /

ADD https://github.com/open-policy-agent/opa/releases/download/v0.60.0/opa_linux_amd64_static opa
RUN chmod +x opa

ADD https://github.com/traefik/traefik/releases/download/v2.10.7/traefik_v2.10.7_linux_amd64.tar.gz traefik.tar.gz
RUN tar --extract --file=traefik.tar.gz traefik

FROM ${BUN}
RUN apt-get update && apt-get install -y redis-server curl

COPY --from=vendor /opa /usr/bin/opa
COPY --from=vendor /traefik /usr/bin/traefik

COPY ./traefik.yml /etc/traefik.yml
COPY ./bundle.tar.gz /bundle.tar.gz
COPY ./entrypoint.sh /entrypoint.sh

COPY --from=build /app/app.js /app.js

USER bun
ENV container=lxc
LABEL org.opencontainers.image.source https://github.com/becojo/ctf-challenges

ENTRYPOINT ["bash", "/entrypoint.sh"]

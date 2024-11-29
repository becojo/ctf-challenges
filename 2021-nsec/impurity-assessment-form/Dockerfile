FROM node:20-bookworm-slim@sha256:a0196893dffad1f1a5723a8c817b45681402be549a8f196bf9c93a5bc30628e3
LABEL org.opencontainers.image.source=https://github.com/becojo/ctf-challenges
WORKDIR /app

RUN apt-get update && apt-get install -y wkhtmltopdf tini
COPY ./package.json ./package-lock.json ./
RUN npm ci

COPY ./index.js ./
COPY ./public ./public
COPY ./views ./views

EXPOSE 20129
ENTRYPOINT ["tini", "--"]
CMD ["node", "index.js"]

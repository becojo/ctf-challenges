FROM php:8-apache@sha256:18332cc2f59b5d953c46c570309fca971c6d1fbf8295b81e7ce582dbb76010d0
LABEL org.opencontainers.image.source=https://github.com/becojo/ctf-challenges

COPY ./www /var/www/html
RUN openssl rand -hex 20 > /secret
RUN echo "FLAG-$(openssl rand -hex 20)" > /motd
RUN echo "FLAG-$(openssl rand -hex 20)" > "/flag-is-here-$(openssl rand -hex 10)"
COPY ./db.sqlite3 /var/www/db.sqlite3

WORKDIR /var/www
RUN tar -czvf /tmp/source.tar.gz html && mv /tmp/source.tar.gz /var/www/html

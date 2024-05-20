#!/usr/bin/env sh

redis-server &
traefik --configFile=/etc/traefik.yml --log.level=DEBUG &
FLAG=FLAG-04162f91789c87849771c60e3fdc16bd opa run --server --addr 127.0.0.1:8181 /bundle.tar.gz &

FLAG=FLAG-2fc6c690e95b6e7cc4d0373b99256ab9 REDIS_FLAG=FLAG-b408c2d105e63ee28e2f90d6b396652c ADMIN_JWT=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiJ9.xAHWTQ9r8rfa-ekvh-PAYRSVYjiKMmkxPEnUSGsEABU bun /app.js

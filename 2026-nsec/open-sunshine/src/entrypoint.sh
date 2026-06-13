#!/bin/bash

su -s /bin/sh part1 -c "PORT=8080 bun --smol /server.js" &
su -s /bin/sh part2 -c "PORT=8081 bun --smol /server.js" &

exec sh -c 'sleep infinity'

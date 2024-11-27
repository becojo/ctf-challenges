FROM openpolicyagent/opa:0.70.0-static@sha256:5679cbbedd1908063b7a68e8af28e662dce4ae3e069b4b5459531b141c6b6ff0 AS vendor

FROM alpine/socat:latest@sha256:7d42e94ae628014cc9c0721d438ac3bfe2c88161e59269ec063c2841b73247eb
LABEL org.opencontainers.image.source=https://github.com/becojo/ctf-challenges

WORKDIR /app
COPY --from=vendor /opa /usr/local/bin/opa
COPY ./entrypoint.sh .
COPY ./bundles ./bundles

EXPOSE 41640
ENTRYPOINT ["socat"]
CMD ["tcp-l:41640,fork", "exec:timeout 60 ./entrypoint.sh"]
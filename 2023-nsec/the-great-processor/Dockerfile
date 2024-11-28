FROM ruby:3.2-alpine@sha256:1336f1998baf42fd295578b47be55cd68b5d6c8eae231d058713529621e12071

RUN apk add socat

COPY challenge.rb /challenge.rb
COPY state.json /state.json

EXPOSE 54098
ENTRYPOINT ["socat"]
CMD ["TCP-LISTEN:54098,reuseaddr,fork", "EXEC:timeout 300 /usr/local/bin/ruby /challenge.rb"]

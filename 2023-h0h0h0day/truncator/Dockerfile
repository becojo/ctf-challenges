FROM cgr.dev/chainguard/ruby:latest-dev@sha256:c4857f0a824435042163e237eaea82eb696153b7d3b40e460be08f1b3e3c1335 AS build

USER root

WORKDIR /app

COPY Gemfile .

RUN bundle lock
RUN bundle install
RUN bundle binstubs --all

COPY app.rb .
COPY config.ru .
COPY views views

RUN echo "FLAG-f6d468c4dd0d44e4a77827e556d56389ca8be401" > /flag

FROM cgr.dev/chainguard/ruby:latest@sha256:51a0fea1884e97fef8ce93285b3f696836046c145adf7e842444da2cfbb6ae1d

LABEL org.opencontainers.image.source=https://github.com/becojo/ctf-challenges

WORKDIR /app

COPY --from=build /usr/lib/ruby/gems/ /usr/lib/ruby/gems/
COPY --from=build /app /app
COPY --from=build /flag /secretdf218f3a40ae20.txt
COPY --from=build /flag /app/secretdf218f3a40ae20.txt

ENV RACK_ENV=production

EXPOSE 36087

ENTRYPOINT ["ruby", "/app/bin/rackup", "--host=0.0.0.0", "--port=36087"]

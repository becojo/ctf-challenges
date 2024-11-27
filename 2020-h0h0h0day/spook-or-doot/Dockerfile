FROM ruby:2.7.1@sha256:b3aab6a052e2397456342d97a4d0591d4b2bf54b1ee6e599867fb95440f22a6c
LABEL org.opencontainers.image.source=https://github.com/becojo/ctf-challenges

WORKDIR /var/www

COPY Gemfile Gemfile.lock ./
RUN bundle

COPY . .

RUN mkdir /var/www/tmp && chown -R www-data:www-data /var/www

RUN echo FLAG-558c00ece57a6b20f3d95ab8cb20aa2a > flag_is_here_f371524b3dd37

EXPOSE 23292
ENTRYPOINT ["bundle", "exec"]
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "23292", "-e", "production"]

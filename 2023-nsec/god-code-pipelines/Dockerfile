FROM hairyhenderson/gomplate:v4.2@sha256:20af20cf82a5b8c14572f756af1ab89d25a42da33823b8eddbe058d60398927f AS vendor

FROM debian:bullseye@sha256:01559430c84e6bc864bed554345d1bfbfa94ac108ab68f39915cae34604b15c3 AS base
LABEL org.opencontainers.image.source=https://github.com/becojo/ctf-challenges
EXPOSE 22

RUN apt-get update && apt-get install -y python3 openssh-server git tini curl
RUN adduser --gecos 'git' --shell /usr/bin/git-shell git
RUN echo git:git | chpasswd
RUN service ssh start

ENV GIT_AUTHOR_NAME="git"
ENV GIT_AUTHOR_EMAIL="git@git.ctf"
ENV GIT_AUTHOR_DATE="2005-04-07T22:13:13"
ENV GIT_COMMITTER_NAME="git"
ENV GIT_COMMITTER_EMAIL="git@git.ctf"
ENV GIT_COMMITTER_DATE="2005-04-07T22:13:13"
RUN git config --global init.defaultBranch main

CMD ["tini", "--", "/usr/sbin/sshd","-D"]

## Prettier
FROM base AS build_prettier
COPY ./prettier /src
RUN git init --bare /repo
RUN git init /src
WORKDIR /src
RUN git add . && git commit -m 'first commit'
RUN git remote add origin /repo
RUN git push origin main
RUN chown -R git:git /repo
COPY ./hooks/prettier.py /repo/hooks/pre-receive

FROM base AS prettier
COPY ./setup_20.x /setup_20.x
RUN bash /setup_20.x
RUN apt-get update && apt-get install -y nodejs
RUN npm install -g prettier
COPY --from=build_prettier /repo /prettier
RUN echo "FLAG-$(openssl rand -hex 20)" > /flag_here_$(openssl rand -hex 8)


## Semgrep
FROM base AS build_semgrep
COPY ./semgrep /src
RUN git init --bare /repo
RUN git init /src
WORKDIR /src
RUN git add . && git commit -m 'first commit'
RUN git remote add origin /repo
RUN git push origin main
RUN chown -R git:git /repo
COPY ./hooks/semgrep.py /repo/hooks/pre-receive

FROM base AS semgrep
RUN apt-get install -y python3-pip
RUN pip install semgrep==0.60.0
COPY --from=build_semgrep /repo /semgrep
RUN echo "FLAG-$(openssl rand -hex 20)" > /flag_here_$(openssl rand -hex 8)


## Gomplate
FROM base AS build_gomplate
COPY ./gomplate /src
RUN git init --bare /repo
RUN git init /src
WORKDIR /src
RUN git add . && git commit -m 'first commit'
RUN git remote add origin /repo
RUN git push origin main
RUN chown -R git:git /repo
COPY ./hooks/gomplate.py /repo/hooks/pre-receive

FROM base AS gomplate
COPY --from=vendor /gomplate /usr/bin/gomplate
COPY --from=build_gomplate /repo /gomplate
RUN echo "FLAG-$(openssl rand -hex 20)" > /flag_here_$(openssl rand -hex 8)

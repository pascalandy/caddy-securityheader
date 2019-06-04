# ---- # ---- # ---- # ---- # ---- # ---- # ----
# Build stage by @abiosoft https://github.com/abiosoft/caddy-docker
#
FROM golang:1.11.2-alpine3.8 as build

# main configs
ARG version="0.11.1"
#ARG plugins="git cors realip expires cache" 

# deps
RUN set -ex && apk add --update --no-cache \
      git

# source
RUN git clone https://github.com/mholt/caddy -b "v${version}" $GOPATH/src/github.com/mholt/caddy
WORKDIR $GOPATH/src/github.com/mholt/caddy
RUN git checkout -b "v${version}"

# plugin helper
RUN go get -v github.com/abiosoft/caddyplug/caddyplug

# plugins (WARNING hardcoded)
RUN for plugin in git cors realip expires cache; do \
      go get -v $(caddyplug package $plugin); \
      printf "package caddyhttp\nimport _ \"$(caddyplug package $plugin)\"" > \
        $GOPATH/src/github.com/mholt/caddy/caddyhttp/$plugin.go ; \
    done

# builder dependency
RUN git clone https://github.com/caddyserver/builds $GOPATH/src/github.com/caddyserver/builds

# build
WORKDIR $GOPATH/src/github.com/mholt/caddy/caddy
RUN git checkout -f
RUN go run build.go
RUN mv caddy /


# ---- # ---- # ---- # ---- # ---- # ---- # ----
# Compress Caddy with upx
#
FROM debian:stable as compress

ARG upx_version="3.94"

# dependencies
RUN apt-get update && apt install -y --no-install-recommends \
      tar \
      xz-utils \
      curl \
      ca-certificates

# get official upx binary
RUN curl --silent --show-error --fail --location -o - \
    "https://github.com/upx/upx/releases/download/v${upx_version}/upx-${upx_version}-amd64_linux.tar.xz" \
    | tar --no-same-owner -C /usr/bin/ -xJ \
    --strip-components 1 upx-${upx_version}-amd64_linux/upx

# copy and compress
COPY --from=build /caddy /usr/bin/caddy
RUN /usr/bin/upx --ultra-brute /usr/bin/caddy

# test
RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins


# ---- # ---- # ---- # ---- # ---- # ---- # ----
# Final image
# alpine is needed as we need curl for healthcheck
#
FROM alpine:3.8

RUN set -ex && apk add --update --no-cache                  \
      curl                                                  \
      tini                                                  \
      tzdata                                                && \
    cp /usr/share/zoneinfo/America/New_York /etc/localtime  && \
    echo "America/New_York" > /etc/timezone                 && \
    apk del tzdata                                          && \
    rm -rf /var/cache/apk/* /tmp/*                          && \
    mkdir -p /caddycache

# labels
LABEL org.label-schema.vcs-url="https://github.com/pascalandy/"
LABEL org.label-schema.version=${version}
LABEL org.label-schema.schema-version="1.0"

# copy binary and ca certs
COPY --from=compress /usr/bin/caddy /bin/caddy
COPY --from=compress /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

# copy default caddyfile
COPY Caddyfile /etc/Caddyfile

# set default caddypath
ENV CADDYPATH=/etc/.caddy

# Copy html. Needed for unit testing
COPY index.html /srv/index.html

# serve from /srv
VOLUME /etc/.caddy /srv
WORKDIR /srv
EXPOSE 2015

#healthcheck
#HEALTHCHECK CMD curl --fail http://localhost:2015/ || exit 1

ENTRYPOINT ["/sbin/tini", "--", "/bin/caddy" ]

CMD ["--conf", "/etc/Caddyfile", "--log", "stdout" ]

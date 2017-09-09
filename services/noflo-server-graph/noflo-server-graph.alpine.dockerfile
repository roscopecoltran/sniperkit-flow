## snippets ############################################################################################################
##
## 1. docker build -t noflo-server-graph --no-cache -f noflo-server-graph.alpine.dockerfile .
## 2. docker run --rm -p 3569:3569 noflo-server-graph
##
########################################################################################################################

## base image
FROM mhart/alpine-node:latest
LABEL maintainer "Michalski Luc <michalski.luc@gmail.com>"

EXPOSE 3569 80 443 2015

## with GOSU
# ENTRYPOINT ["/usr/local/sbin/gosu"]
# CMD ["app", "/app/noflo-server-graph"]

## with TINI
# ENTRYPOINT ["/sbin/tini"]
# CMD [ "--", "/usr/bin/entrypoint.sh"]

CMD ["/usr/bin/noflo-nodejs"]

## container - info
ARG CONTAINER_OS=${CONTAINER_OS:-"linux"}
ARG CONTAINER_ARCH=${CONTAINER_ARCH:-"amd64"}

## caddy - features
ARG CADDY_FEATURES=${CADDY_FEATURES:-""}
# ARG CADDY_FEATURES=${CADDY_FEATURES:-"hook.service,http.awslambda,http.cache,http.cors,http.expires,http.git,http.gopkg,http.grpc,http.ipfilter,http.jwt,http.nobots,http.ratelimit,http.realip,http.reauth,net,tls.dns.cloudflare,tls.dns.digitalocean,tls.dns.gandi,tls.dns.googlecloud,tls.dns.linode,tls.dns.ovh,tls.dns.rackspace"}

## alpine - apk
ARG APK_BUILD=${APK_BUILD:-"libcap curl wget tar gzip unzip libwebsockets-dev libmagic"}
ARG APK_RUNTIME=${APK_RUNTIME:-"su-exec tini libwebsockets websocket++"}
ARG APK_INTERACTIVE=${APK_INTERACTIVE:-"nano bash tree jq"}

## security
ARG GOSU_VERSION=${GOSU_VERSION:-"1.10"}

## dependencies (yarn or npm)
# for file in /shared/dependencies/nodejs/*
ARG DEPENDENCY_NODEJS_EXEC=${DEPENDENCY_NODEJS_EXEC:-"yarn"}
ARG DEPENDENCY_NODEJS_PATHS=${DEPENDENCY_NODEJS_PATHS:-"/shared/dependencies/nodejs/global /shared/dependencies/nodejs/local"}

## env variables
ENV UID="991" \
    GID="991" \
    CADDY_SRC_URL="https://caddyserver.com/download/build?os=${CONTAINER_OS}&arch=${CONTAINER_ARCH}&features=${CADDY_FEATURES}"

## Install Gosu to /usr/local/bin/gosu
ADD https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${CONTAINER_ARCH} /usr/local/sbin/gosu

COPY ./shared/dependencies/nodejs    /shared/dependencies/nodejs

## Install build and runtime dependencies
RUN \
    chmod +x /usr/local/sbin/gosu \
        && apk add --no-cache --no-progress --update --virtual .deps.build ${APK_BUILD} \
        && apk add --no-cache --no-progress --update --virtual .deps.runtime ${APK_RUNTIME} \
        && apk add --no-cache --no-progress --update --virtual .deps.interactive ${APK_INTERACTIVE} \
    \
    ## Install dependencies 
    \
        && echo "[NODEJS] - [START] with \"${DEPENDENCY_NODEJS_EXEC}\"" \
            && for DPP in ${DEPENDENCY_NODEJS_PATHS}; do \
                cd ${DPP} \
                    && ls -l \
                        && if [ -f package.json ]; then ${DEPENDENCY_NODEJS_EXEC} install ; fi ; \
        done \
        && echo "[NODEJS] - [END] with \"${DEPENDENCY_NODEJS_EXEC}\"" \
    \
    ## Download Caddy
    \
        && mkdir -p /tmp/caddy \
        && cd /tmp/caddy \
        && wget -nc -O caddy.tar.gz "$CADDY_SRC_URL" \
        \
        && tar xvf /tmp/caddy/caddy.tar.gz -C /tmp/caddy \
        && mv /tmp/caddy/caddy /usr/local/bin/caddy \
    \
        # Set permission to bind port 80 and 443
        && setcap cap_net_bind_service=+ep /usr/local/bin/caddy \
    \
    # Cleaning
        \
        && adduser -D app -h /shared/data -s /bin/sh \
        \
        && apk del --no-cache .deps.build \
        \
        && rm -rf /tmp/caddy

## config files
COPY ./docker/internal/entrypoint.sh    /usr/bin/entrypoint.sh
COPY ./docker/internal/nsswitch.conf    /etc/nsswitch.conf
COPY ./shared/conf.d/caddy/Caddyfile    /shared/conf.d/caddy/Caddyfile

VOLUME ["/shared/conf.d/caddy", "/shared/logs/caddy"]
WORKDIR /shared

CMD ["/sbin/tini", "--", "/usr/bin/entrypoint.sh"]
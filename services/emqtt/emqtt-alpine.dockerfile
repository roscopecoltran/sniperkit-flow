###########################################################################
#         
#  Build the image:                                                       
#    $ docker build -t emqtt:10-alpine3.6 --no-cache .                                     # longer but more accurate
#    $ docker build -t emqtt:10-alpine3.6 .                                                # faster but increase mistakes
#                                                                         
#  Run the container:                                                     
#    $ docker run -it --rm -v $(pwd)/shared:/shared -p 18083:18083 -p 1883:1883 emqtt:10-alpine3.6
#    $ docker run -d --name emqtt -p 18083:18083 -p 1883:1883 -v $(pwd)/shared:/shared emqtt:10-alpine3.6
#                                                                     
###########################################################################

FROM alpine:3.6
LABEL maintainer "Luc Michalski <michalski.luc@gmail.com>"

ARG EMQ_VERSION=${EMQ_VERSION:-"v2.3-beta.3"}

COPY ./docker/internal/entrypoint.sh /start.sh

RUN set -ex \
    # add build deps, remove after build
    && apk --no-cache add --virtual .build-deps \
        build-base \
        # gcc \
        # make \
        bsd-compat-headers \
        perl \
        erlang \
        erlang-public-key \
        erlang-syntax-tools \
        erlang-erl-docgen \
        erlang-gs \
        erlang-observer \
        erlang-ssh \
        #erlang-ose \
        erlang-cosfiletransfer \
        erlang-runtime-tools \
        erlang-os-mon \
        erlang-tools \
        erlang-cosproperty \
        erlang-common-test \
        erlang-dialyzer \
        erlang-edoc \
        erlang-otp-mibs \
        erlang-crypto \
        erlang-costransaction \
        erlang-odbc \
        erlang-inets \
        erlang-asn1 \
        erlang-snmp \
        erlang-erts \
        erlang-et \
        erlang-cosnotification \
        erlang-xmerl \
        erlang-typer \
        erlang-coseventdomain \
        erlang-stdlib \
        erlang-diameter \
        erlang-hipe \
        erlang-ic \
        erlang-eunit \
        #erlang-webtool \
        erlang-mnesia \
        erlang-erl-interface \
        #erlang-test-server \
        erlang-sasl \
        erlang-jinterface \
        erlang-kernel \
        erlang-orber \
        erlang-costime \
        erlang-percept \
        erlang-dev \
        erlang-eldap \
        erlang-reltool \
        erlang-debugger \
        erlang-ssl \
        erlang-megaco \
        erlang-parsetools \
        erlang-cosevent \
        erlang-compiler \
    # add fetch deps, remove after build
    && apk add --no-cache --virtual .fetch-deps \
        git \
        wget \
    # add run deps, never remove
    && apk add --no-cache --virtual .run-deps \
        ncurses-terminfo-base \
        ncurses-terminfo \
        ncurses-libs \
        readline \
    # add latest rebar
    && git clone -b ${EMQ_VERSION} https://github.com/emqtt/emq-relx.git /emqttd \
    && cd /emqttd \
    && make \
    && mkdir -p /opt && mv /emqttd/_rel/emqttd /opt/emqttd \
    && cd / && rm -rf /emqttd \
    && mv /start.sh /opt/emqttd/start.sh \
    && chmod +x /opt/emqttd/start.sh \
    && ln -s /opt/emqttd/bin/* /usr/local/bin/ \
    # removing fetch deps and build deps
    && apk --purge del .build-deps .fetch-deps \
    && rm -rf /var/cache/apk/*

WORKDIR /opt/emqttd

# start emqttd and initial environments
CMD ["/opt/emqttd/start.sh"]

RUN adduser -D -u 1000 emqtt

RUN chgrp -Rf root /opt/emqttd && chmod -Rf g+w /opt/emqttd \
      && chown -Rf emqtt /opt/emqttd

USER emqtt

VOLUME ["/shared/logs/emqttd", "/shared/data/emqttd", "/shared/lib/emqttd", "/shared/conf.d/emqttd"]

# emqttd will occupy these port:
# - 1883 port for MQTT
# - 8883 port for MQTT(SSL)
# - 8083 for WebSocket/HTTP
# - 8084 for WSS/HTTPS
# - 8080 for mgmt API
# - 18083 for dashboard
# - 4369 for port mapping
# - 6000-6999 for distributed node
EXPOSE 1883 8883 8083 8084 8080 18083 4369 6000-6999
###########################################################################
#         
#  Build the image:                                                       
#    $ docker build -t tika-nginx:1.16-alpine3.6 --no-cache -f tika-nginx.alpine.dockerfile .    # longer but more accurate
#    $ docker build -t tika-nginx:1.16-alpine3.6 .                                               # faster but increase mistakes
#                                                                         
#  Run the container:                                                     
#  $ docker run -it --rm -v $(pwd)/shared:/shared -p 9998:9998 -p 80:80 -p 443:443 -p 9001:9001 tika-nginx:1.16-alpine3.6
#  $ docker run -d --name tika-nginx -p 9998:9998 -p 80:80 -p 443:443 -p 9001:9001 -v $(pwd)/shared:/shared tika-nginx:1.16-alpine3.6
#                                                                     
###########################################################################

FROM alpine:3.6
LABEL maintainer "Luc Michalski <michalski.luc@gmail.com>"

ARG TIKA_VERSION=${TIKA_VERSION:-"1.16"}
EXPOSE 9001 9998 80 443

ADD http://apache.mediamirrors.org/tika/tika-server-${TIKA_VERSION}.jar /opt/tika-server-${TIKA_VERSION}.jar

# supervisord, apacke-tika, nginx ports
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

ENV JAVA_HOME=${JAVA_HOME:-"/usr/lib/jvm/default-jvm"} \
    PYTHON_VERSION=${PYTHON_VERSION:-"2.7.13-r1"} \
    PY_PIP_VERSION=${PY_PIP_VERSION:-"9.0.1-r1"} \
    SUPERVISOR_VERSION=${SUPERVISOR_VERSION:-"3.3.1"} \
    NGINX_VERSION=${NGINX_VERSION:-"1.13.1"} \
    CLRS_PATH=c${CLRS_PATH:-"lrs"}

# install nginx
VOLUME ["/var/cache/nginx"]

# Install runtime dependancies
RUN \
    apk add --no-cache --virtual .run-deps \
    ca-certificates openssl pcre zlib

RUN \
    # Install build and runtime packages
    apk add --no-cache --no-progress --update --virtual .build-deps \
            build-base linux-headers openssl-dev pcre-dev wget zlib-dev \
    \
    # download unpack nginx-src
    && mkdir /tmp/nginx && cd /tmp/nginx \
    && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar xzf nginx-${NGINX_VERSION}.tar.gz \
    && cd nginx-${NGINX_VERSION} \
    #compile
    && ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=www-data \
    --group=www-data \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_realip_module \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-compat \
    --with-file-aio \
    --with-http_v2_module \
    && make \
    && make install \
    && make clean \
    \
    # strip debug symbols from the binary (GREATLY reduces binary size)
        && strip -s /usr/sbin/nginx \
    \
    # add www-data user and create cache dir
        && adduser -D www-data \
    \
    # remove NGINX dev dependencies
        && apk del .build-deps \
    \
    # other clean up
        && cd / \
        && rm /etc/nginx/*.default \
        && rm -rf /var/cache/apk/* \
        && mkdir -p /shared/conf.d/nginx \
        && mkdir -p /shared/logs/nginx \
        && rm -rf /tmp/* \
        && rm -rf /var/www/* \
        && echo "installed nginx" \
    \
    # install java/tika
    && apk add --no-cache --no-progress --update openjdk8-jre-base curl gnupg && \
        \
        && rm -rf /var/cache/apk/* \
        && mkdir -p /shared/conf.d/tika /shared/data/tika /shared/logs/tika \
        && echo "installed java" \
    \
    # Install supervisord
    && apk add --no-cache --no-progress --update python=$PYTHON_VERSION py-pip=$PY_PIP_VERSION \
        \
        && pip install supervisor==$SUPERVISOR_VERSION \
        && mkdir -p etc/supervisor/conf.d \
        && mkdir -p /shared/logs/supervisord \
        && rm -rf /var/cache/apk/* \
        && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem \
        && echo "installed supervisord"

# since Jul 13, 2017: get invalid jar file when using this dynamic approach
#   && curl -sSL https://people.apache.org/keys/group/tika.asc -o /tmp/tika.asc \
#   && gpg --import /tmp/tika.asc \
#   && curl -sSL "$TIKA_SERVER_URL.asc" -o /tmp/tika-server-1-15.jar.asc \
#   && NEAREST_TIKA_SERVER_URL=$(curl -sSL http://www.apache.org/dyn/closer.cgi/${TIKA_SERVER_URL#https://www.apache.org/dist/}\?asjson\=1 \
#       | awk '/"path_info": / { pi=$2; }; /"preferred":/ { pref=$2; }; END { print pref " " pi; };' \
#       | sed -r -e 's/^"//; s/",$//; s/" "//') \
#   && echo "Nearest mirror: $NEAREST_TIKA_SERVER_URL" \
#   && curl -sSL "$NEAREST_TIKA_SERVER_URL" -o /tika-server-1.15.jar

# Supervisord configuration
COPY shared/conf.d/supervisord/supervisord.conf /etc/supervisor/supervisord.conf

# todo:use github build
COPY shared/www/ /etc/nginx/html/

# nginx configuration
COPY shared/conf.d/nginx/nginx.conf /etc/nginx/nginx.conf

VOLUME ["/shared/logs/tika", "/shared/data/tika", "/shared/lib/tika", "/shared/conf.d/tika"]

# tika-server
# COPY docker/tika-server-1.16.jar /tika-server-1.16.jar

# Add and define entrypoint
# -------------------------
# COPY entrypoint.sh /usr/bin/entrypoint.sh
# RUN chmod u+x /usr/bin/entrypoint.sh
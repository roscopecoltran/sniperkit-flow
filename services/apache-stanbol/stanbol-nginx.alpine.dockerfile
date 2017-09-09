###########################################################################
#         
#  Build the image:                                                       
#    $ docker build -t stanbol-nginx:1.16-alpine3.6 --no-cache -f stanbol-nginx.alpine.dockerfile . # longer but more accurate
#    $ docker build -t stanbol-nginx:1.16-alpine3.6 .                                               # faster but increase mistakes
#                                                                         
#  Run the container:                                                     
#  $ docker run -it --rm -v $(pwd)/shared:/shared -p 9998:9998 -p 80:80 -p 443:443 -p 9001:9001 stanbol-nginx:1.16-alpine3.6
#  $ docker run -d --name stanbol-nginx -p 9998:9998 -p 80:80 -p 443:443 -p 9001:9001 -v $(pwd)/shared:/shared stanbol-nginx:1.16-alpine3.6
#                                                                     
###########################################################################

FROM alpine:3.6
LABEL maintainer "Luc Michalski <michalski.luc@gmail.com>"

ARG STANBOL_VERSION=${STANBOL_VERSION:-"1.0.0"}
EXPOSE 8080

ADD http://apache.mediamirrors.org/stanbol/apache-stanbol-${STANBOL_VERSION}-source-release.tar.gz  /opt/stanbol-${STANBOL_VERSION}.tar.gz

# supervisord, apacke-stanbol, nginx ports

CMD ["/bin/bash"]
# ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]


ENV JAVA_HOME=${JAVA_HOME:-"/usr/lib/jvm/default-jvm"} \
    PYTHON_VERSION=${PYTHON_VERSION:-"2.7.13-r1"} \
    PY_PIP_VERSION=${PY_PIP_VERSION:-"9.0.1-r1"} \
    SUPERVISOR_VERSION=${SUPERVISOR_VERSION:-"3.3.1"} \
    NGINX_VERSION=${NGINX_VERSION:-"1.13.1"} \
    CLRS_PATH=c${CLRS_PATH:-"lrs"}

# install nginx
VOLUME ["/var/cache/nginx"]

RUN \   
    # Install runtime dependancies    
    apk add --no-cache --virtual .run-deps ca-certificates openssl pcre zlib nano bash \
    \
    # Install build and runtime packages
        && apk add --no-cache --no-progress --update --virtual .build-deps \
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
    # install java/stanbol
    && apk add --no-cache --no-progress --update openjdk8-jre-base curl gnupg && \
        \
        && cd /opt \
        && pwd \
        && tar xvf stanbol-${STANBOL_VERSION}.tar.gz \
        && cd stanbol-${STANBOL_VERSION} \
        && mvn clean install \
        \
        && rm -rf /var/cache/apk/* \
        && mkdir -p /shared/conf.d/stanbol /shared/data/stanbol /shared/logs/stanbol \
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
#   && curl -sSL https://people.apache.org/keys/group/stanbol.asc -o /tmp/stanbol.asc \
#   && gpg --import /tmp/stanbol.asc \
#   && curl -sSL "$STANBOL_SERVER_URL.asc" -o /tmp/stanbol-server-1-15.jar.asc \
#   && NEAREST_STANBOL_SERVER_URL=$(curl -sSL http://www.apache.org/dyn/closer.cgi/${STANBOL_SERVER_URL#https://www.apache.org/dist/}\?asjson\=1 \
#       | awk '/"path_info": / { pi=$2; }; /"preferred":/ { pref=$2; }; END { print pref " " pi; };' \
#       | sed -r -e 's/^"//; s/",$//; s/" "//') \
#   && echo "Nearest mirror: $NEAREST_STANBOL_SERVER_URL" \
#   && curl -sSL "$NEAREST_STANBOL_SERVER_URL" -o /stanbol-server-1.15.jar

# Supervisord configuration
COPY shared/conf.d/supervisord/supervisord.conf /etc/supervisor/supervisord.conf

# todo:use github build
COPY shared/www/ /etc/nginx/html/

# nginx configuration
COPY shared/conf.d/nginx/nginx.conf /etc/nginx/nginx.conf

VOLUME ["/shared/logs/stanbol", "/shared/data/stanbol", "/shared/lib/stanbol", "/shared/conf.d/stanbol"]

# stanbol-server
# COPY docker/stanbol-server-1.16.jar /stanbol-server-1.16.jar

# Add and define entrypoint
# -------------------------
# COPY entrypoint.sh /usr/bin/entrypoint.sh
# RUN chmod u+x /usr/bin/entrypoint.sh

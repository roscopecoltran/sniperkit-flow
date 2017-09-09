#!/bin/sh

addgroup -g ${GID} caddy
adduser -h /app/caddy -s /bin/sh -D -G caddy -u ${UID} caddy

chown -R caddy:caddy /app/caddy
chown -R caddy:caddy /shared

su-exec caddy:caddy sh -c "/usr/local/bin/caddy --version"
su-exec caddy:caddy sh -c "/usr/local/bin/caddy -agree --conf /shared/conf.d/caddy/Caddyfile"
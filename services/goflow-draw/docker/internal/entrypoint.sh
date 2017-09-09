#!/bin/sh
set -x
set -e

addgroup -g ${GID} caddy
adduser -h /app/caddy -s /bin/sh -D -G caddy -u ${UID} caddy

chown -R caddy:caddy /app/caddy
chown -R caddy:caddy /shared

su-exec caddy:caddy sh -c "/usr/local/bin/caddy --version"
su-exec caddy:caddy sh -c "/usr/local/bin/caddy -agree --conf /shared/conf.d/caddy/Caddyfile"

clear
echo

DIR=$(dirname "$0")
echo "$DIR"
. ${DIR}/common.sh

pwd

if [[ -d ./$1 ]]; then
	cd ./$1
else
	cd /app
fi

case "$1" in

  'interactive')
	apk add --update --no-cache --no-progress --virtual interactive-deps ${APK_INTERACTIVE} ${APK_INTERACTIVE_CUSTOM}
  	exec /bin/bash
	;;

  'bash')
	apk add --update --no-cache --no-progress bash
  	exec /bin/bash
	;;

  'dev')
	apk add --update --no-cache --no-progress --virtual interactive-deps ${APK_INTERACTIVE} ${APK_INTERACTIVE_CUSTOM}
	apk add --update --no-cache --no-progress --virtual build-deps ${APK_BUILD} ${APK_BUILD_CUSTOM}
  	exec /bin/bash
	;;

  *)
  	exec $@
	;;

esac
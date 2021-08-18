#!/bin/sh

set -eu

if [ ! -f "/etc/frps/frps.ini" ];then
  cp /conf/frps.ini /etc/frps/frps.ini
fi

if [ "$(id -u)" = '0' ]; then
  chown "${PUID}:${PGID}" "${HOME}" \
    && exec su-exec "${PUID}:${PGID}" \
       env HOME="$HOME" "$@"
else
  exec "$@"
fi

#!/bin/sh
# Railway boot wrapper for Verdaccio.
# - Railway mounts the volume root-owned, so chown it, then drop to the image user (busybox su).
# - Write the htpasswd admin line from VERDACCIO_ADMIN_PASSWORD on every boot, so the
#   variable is the source of truth and the registry is never open for self-signup.
# - Listen on IPv4 and IPv6 at $PORT (Railway injects 8080).
set -e

STORAGE=/verdaccio/storage
UID_RUN=10001
GID_RUN=65533
export PORT_USE="${PORT:-4873}"
ADMIN_USER="${VERDACCIO_ADMIN_USER:-admin}"

if [ -z "$VERDACCIO_ADMIN_PASSWORD" ]; then
  echo "railway-entrypoint: VERDACCIO_ADMIN_PASSWORD is not set" >&2
  exit 1
fi

mkdir -p "$STORAGE/data"
HASH="$(NODE_PATH=/usr/local/lib/node_modules/verdaccio/node_modules node -e '
const bcrypt = require("bcryptjs");
process.stdout.write(bcrypt.hashSync(process.env.VERDACCIO_ADMIN_PASSWORD, 10).replace(/^\$2[ab]\$/, "$2y$"));
')"
printf '%s:%s\n' "$ADMIN_USER" "$HASH" > "$STORAGE/htpasswd"
chown -R "$UID_RUN:$GID_RUN" "$STORAGE"
chmod 0600 "$STORAGE/htpasswd"
echo "railway-entrypoint: storage owner=$(stat -c %u:%g "$STORAGE") admin=$ADMIN_USER port=$PORT_USE"

if [ -z "$VERDACCIO_PUBLIC_URL" ] && [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
  export VERDACCIO_PUBLIC_URL="https://$RAILWAY_PUBLIC_DOMAIN"
fi
unset VERDACCIO_ADMIN_PASSWORD

exec su -m -s /bin/sh verdaccio -c 'exec /usr/bin/dumb-init -- verdaccio --config /verdaccio/railway-config.yaml --listen "http://0.0.0.0:$PORT_USE" --listen "http://[::]:$PORT_USE"'

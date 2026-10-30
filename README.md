# verdaccio-railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/verdaccio-or-just-updated-private-npm-re?referralCode=Z1xivh&utm_medium=integration&utm_source=template&utm_campaign=generic)

**Deploy on Railway:** [Verdaccio template](https://railway.com/deploy/verdaccio-or-just-updated-private-npm-re?referralCode=Z1xivh&utm_medium=integration&utm_source=template&utm_campaign=generic)

Verdaccio 7 private npm registry packaged for Railway.

- Closed by default: self-registration is off (`max_users: -1`) and every package needs a login.
- The admin account is written to the htpasswd file at every boot from `VERDACCIO_ADMIN_PASSWORD`.
- Data lives on the volume mounted at `/verdaccio/storage`; the entrypoint chowns the root-owned Railway mount and drops to uid 10001.
- Listens on `$PORT`, IPv4 and IPv6.
- Packages not held locally are proxied from registry.npmjs.org for authenticated users.

Token login uses HTTP Basic on the user route, with the same credentials repeated in the JSON body:

    curl -s -u "admin:$VERDACCIO_ADMIN_PASSWORD" -X PUT \
      -H 'content-type: application/json' \
      -d "{\"name\":\"admin\",\"password\":\"$VERDACCIO_ADMIN_PASSWORD\"}" \
      https://HOST/-/user/org.couchdb.user:admin

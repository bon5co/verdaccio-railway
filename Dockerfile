# Verdaccio for Railway: closed registry, admin bootstrapped from a variable.
FROM verdaccio/verdaccio:7.0.2@sha256:5623458a61100ff2c89526752e8ea2db58ae2d494fa202c18bf4a508ec46892c

USER root
ENV VERDACCIO_ADMIN_USER=admin
COPY config.yaml /verdaccio/railway-config.yaml
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod 0755 /usr/local/bin/railway-entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]

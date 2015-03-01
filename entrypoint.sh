#!/bin/sh

if [ ! -f /etc/graphite-web/local_settings.py ]; then
	if [ "$GRAPHITE_SECRET_KEY" = "UNSAFE_DEFAULT" ]; then
		GRAPHITE_SECRET_KEY=$(
			dd if=/dev/urandom bs=1 count=100 2>/dev/null |
			tr -dc '[:alnum:]'
			)

		export GRAPHITE_SECRET_KEY
	fi

	envsubst \
		< /etc/graphite-web/local_settings.py.in \
		> /etc/graphite-web/local_settings.py
fi

if [ ! -f /var/lib/graphite-web/graphite.db ]; then
	chown -R apache:apache /var/lib/graphite-web
	runuser -u apache -- graphite-manage syncdb --noinput
fi

exec "$@"


#!/bin/sh

: ${GRAPHITE_SECRET_KEY:="UNSAFE_DEFAULT"}
: ${GRAPHITE_TIME_ZONE:="UTC"}

libdir=/var/lib/graphite-web
logdir=/var/log/httpd
sysconfdir=/etc/graphite-web

if [ ! -d $logdir ]; then
	install -d $logdir -o apache -g apache
fi

chown -R apache:apache $logdir

if [ ! -d $libdir ]; then
	install -d $libdir -o apache -g apache
fi

chown -R apache:apache /var/lib/graphite-web

if [ ! -f /var/lib/graphite-web/graphite.db ]; then
	runuser -u apache -- graphite-manage syncdb --noinput
fi

if [ ! -f /etc/graphite-web/local_settings.py ]; then
	if [ "$GRAPHITE_SECRET_KEY" = "UNSAFE_DEFAULT" ]; then
		GRAPHITE_SECRET_KEY=$(
			dd if=/dev/urandom bs=1 count=100 2>/dev/null |
			tr -dc '[:alnum:]'
			)

		export GRAPHITE_SECRET_KEY
	fi

	envsubst \
		< $sysconfdir/local_settings.py.in \
		> $sysconfdir/local_settings.py
fi

exec "$@"


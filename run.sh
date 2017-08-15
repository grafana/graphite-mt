#!/bin/bash



#initialize django
PYTHONPATH=/opt/graphite/webapp /opt/graphite/bin/django-admin.py collectstatic --noinput --settings=graphite.settings
PYTHONPATH=/opt/graphite/webapp /opt/graphite/bin/django-admin.py migrate --settings=graphite.settings --run-syncd
chown -R www-data:www-data /opt/graphite/storage


# start apache
. /etc/apache2/envvars
export WSGI_PROCESSES=${WSGI_PROCESSES:-2}
export WSGI_THREADS=${WSGI_THREADS:-2}
export WSGI_INACTIVITY_TIMEOUT=${WSGI_INACTIVITY_TIMEOUT:-120}

ARGS="-DFOREGROUND"
if [ ! -z "$SINGLE_TENANT" ]; then
	ARGS="$ARGS -DSingleTenant"
fi

if [ ! -z "$GRAPHITE_BASIC" ]; then
	ARGS="$ARGS -DGraphiteBasic"
fi

exec apache2 $ARGS
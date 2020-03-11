#!/bin/bash



#initialize django
PYTHONPATH=/opt/graphite/webapp /opt/graphite/bin/django-admin.py collectstatic --noinput --settings=graphite.settings
PYTHONPATH=/opt/graphite/webapp /opt/graphite/bin/django-admin.py migrate --settings=graphite.settings --run-syncd
chown -R www-data:www-data /opt/graphite/storage


# start apache
. /etc/apache2/envvars
export GRAPHITE_WSGI_PROCESSES=${GRAPHITE_WSGI_PROCESSES:-4}
export GRAPHITE_WSGI_THREADS=${GRAPHITE_WSGI_THREADS:-1}
export GRAPHITE_WSGI_INACTIVITY_TIMEOUT=${GRAPHITE_WSGI_INACTIVITY_TIMEOUT:-120}
export GRAPHITE_WSGI_REQUEST_TIMEOUT=${GRAPHITE_WSGI_REQUEST_TIMEOUT:-65}
export GRAPHITE_WSGI_MEMORY_LIMIT=${GRAPHITE_WSGI_MEMORY_LIMIT:-10737418240}
export GRAPHITE_WSGI_VIRTUAL_MEMORY_LIMIT=${GRAPHITE_WSGI_VIRTUAL_MEMORY_LIMIT:-10737418240}
export GRAPHITE_WSGI_MAX_REQUESTS=${GRAPHITE_WSGI_MAX_REQUESTS:-1000}

ARGS="-DFOREGROUND"

if [ -n "$SINGLE_TENANT" ]; then

	# legacy values like "yes", "TRUE" set to 1
	[[ $SINGLE_TENANT =~ ^[0-9]+$ ]] || export SINGLE_TENANT=1

	ARGS="$ARGS -DSingleTenant"
fi

if [ ! -z "$GRAPHITE_BASIC" ]; then
	ARGS="$ARGS -DGraphiteBasic"
fi

exec apache2 $ARGS

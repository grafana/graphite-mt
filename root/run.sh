#!/bin/ash

trap exit INT TERM KILL QUIT

set -o notify
set -o errexit
set -o verbose
set -o xtrace

export GRAPHITE_WSGI_PROCESSES=${GRAPHITE_WSGI_PROCESSES:-2}
export GRAPHITE_WSGI_THREADS=${GRAPHITE_WSGI_THREADS:-2}
export GRAPHITE_WSGI_INACTIVITY_TIMEOUT=${GRAPHITE_WSGI_INACTIVITY_TIMEOUT:-120}
export GRAPHITE_WSGI_REQUEST_TIMEOUT=${GRAPHITE_WSGI_REQUEST_TIMEOUT:-65}
export GRAPHITE_WSGI_MEMORY_LIMIT=${GRAPHITE_WSGI_MEMORY_LIMIT:-10737418240}
export GRAPHITE_WSGI_VIRTUAL_MEMORY_LIMIT=${GRAPHITE_WSGI_VIRTUAL_MEMORY_LIMIT:-10737418240}
export GRAPHITE_WSGI_MAX_REQUESTS=${GRAPHITE_WSGI_MAX_REQUESTS:-1000}

graphite-web-proxy \
  -logtostderr \
  -tsdb-url $TSDB_URL \
  -api-key $TSDB_KEY &

PYTHONPATH=/opt/graphite/webapp gunicorn \
  wsgi \
  -u graphite \
  -g graphite \
  --workers=$GUNICORN_WORKERS \
  --bind=0.0.0.0:8080 \
  --preload \
  --pythonpath=/opt/graphite/webapp/graphite &

caddy -http2 -quic -conf /Caddyfile &

wait

# graphite-web

`graphite-web` provides a [Graphite](https://graphiteapp.org/) UI installation tailored for running with a [metrictank](https://github.com/raintank/metrictank) backend such as hosted Grafana from GrafanaLabs.

When run, the container will expose Graphite via HTTP on port 80.

## Building

To build the image simply checkout this repo:

```bash
git clone https://github.com/sovrn/graphite-web.git
cd graphite-web
docker build --force-rm --compress -t graphite-web ./
```

## Running the image

This image includes [graphite-web-proxy](https://github.com/raintank/graphite-web-proxy), and requires the following variables:

- `TSDB_KEY`: Your Metrictank API key
- `TSDB_URL`: Your Metrictank hosted metrics URL

```bash
docker run -dp 80:80 -e TSDB_KEY=API_KEY -e TSDB_URL=TSDB_URL --name graphite-web graphite-web
```

## Tunables

Additional environment variables can be set to adjust performance.

### metrictank

- `SINGLE_TENANT`:
  - if set to a number, will configure the Graphite installation to pass that `x-org-id` to metrictank.
  - if set to a any non-empty string, will configure the Graphite installation to pass  `"x-org-id: 1"` header to metrictank.
  - if not set, all requests to Graphite must include a `"x-org-id"` header with a valid orgId or metrictank must be configured with `multi_tenant=false` otherwise authentication will fail.

### Gunicorn

- `GUNICORN_WORKERS`: (4) Sets the number of workers that Gunicorn will spawn

### Graphite-web

- `GRAPHITE_ALLOWED_HOSTS`: (*) In Django 1.5+ set this to the list of hosts your graphite instances is accessible as. See: <https://docs.djangoproject.com/en/dev/ref/settings/#std:setting-ALLOWED_HOSTS>
- `GRAPHITE_CLUSTER_SERVERS`: (127.0.0.1:8181) The address of your Graphite cluster backend, which defaults to the local [graphite-web-proxy](https://github.com/raintank/graphite-web-proxy).
- `GRAPHITE_DEBUG`: (false) Enable full debug page display on exceptions (Internal Server Error pages)
- `GRAPHITE_DEFAULT_CACHE_DURATION`: (0) Duration to cache metric data and graphs
- `GRAPHITE_FIND_CACHE_DURATION`: (0) Time to cache remote metric find results
- `GRAPHITE_LOG_CACHE_PERFORMANCE`: (true) log cache performance information
- `GRAPHITE_LOG_RENDERING_PERFORMANCE`: (true) log performance information
- `GRAPHITE_LOG_ROTATION`: (true) rotate logs
- `GRAPHITE_LOG_ROTATION_COUNT`: (1) number of logs to keep
- `GRAPHITE_MAX_FETCH_RETRIES`: (2) Number of retries for a specific remote data fetch
- `GRAPHITE_POOL_WORKERS`: (1) A baseline number of workers that should always be created
- `GRAPHITE_POOL_WORKERS_PER_BACKEND`: (8) The number of worker threads that should be created per backend server
- `GRAPHITE_REMOTE_FETCH_TIMEOUT`: (60) Timeout to fetch series data
- `GRAPHITE_REMOTE_FIND_TIMEOUT`: (30) Timeout for metric find requests
- `GRAPHITE_REMOTE_RETRY_DELAY`: (10) Time before retrying a failed remote webapp
- `GRAPHITE_SECRET_KEY`: (UNSAFE_DEFAULT)  Set this to a long, random unique string to use as a secret key for this install
- `GRAPHITE_STATSD_HOST`: ("") If set, django_statsd.middleware.GraphiteRequestTimingMiddleware and django_statsd.middleware.GraphiteMiddleware will be enabled.
- `GRAPHITE_TIME_ZONE`: (Etc/UTC) Set your local timezone
- `GRAPHITE_USE_WORKER_POOL`: (true) Creates a pool of worker threads to which tasks can be dispatched

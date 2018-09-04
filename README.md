# Graphite-mt

Graphite-mt provides a [graphite](https://graphiteapp.org/) installation tailored for running with a [metrictank](https://github.com/raintank/metrictank) backend.

When run, the container will expose graphite via HTTP on port 80.


## running the image
For correct operation, the GRAPHITE_CLUSTER_SERVERS environment variable must be set with the host:port of the metrictank server (or LB address if running a cluster)

```
docker run -p 80:80 -e GRAPHITE_CLUSTER_SERVERS=metrictank:6060 raintank/graphite-mt
```

## Tunables
Additional environment variables can be set to adjust performance.

### metrictank
* SINGLE_TENANT: 
  - if set to a number, will configure the graphite installation to pass that x-org-id to metrictank.
  - if set to a any non-empty string, will configure the graphite installation to pass  "x-org-id: 1" header to metrictank.
  - if not set, all requests to graphite must include a "x-org-id" header with a valid orgId or metrictank must be configured with multi_tenant=false
    otherwise authentication will fail.

### MOD_WSGI
* WSGI_PROCESSES: (2) the number of WSGI daemon processes that should be started
* WSGI_THREADS: (2) the number of threads to be created to handle requests in each daemon process
* WSGI_INACTIVITY_TIMEOUT: (120) the maximum number of seconds allowed to pass before the daemon process is shutdown and restarted when the daemon process has entered an idle state
* WSGI_REQUEST_TIMEOUT: (65) maximum number of seconds that a request is allowed to run before the daemon process is restarted
* WSGI_MEMORY_LIMIT: (10737418240 aka 10Gi) maximum amount of memory a daemon process can use (on platforms that support it)
* WSGI_VIRTUAL_MEMORY_LIMIT: (10737418240 aka 10Gi) maximum amount of virtual memory a daemon process can use (on platforms that support it)
* WSGI_MAX_REQUESTS: (1000) limit on the number of requests a daemon process should process before it is shutdown and restarted.
* WSGI_REQUEST_TIMEOUT: (120) the maximum number of seconds that a request is allowed to run before the daemon process is restarted.

### Graphite-web
* GRAPHITE_SECRET_KEY: (UNSAFE_DEFAULT)  Set this to a long, random unique string to use as a secret key for this install
* GRAPHITE_ALLOWED_HOSTS: (*) In Django 1.5+ set this to the list of hosts your graphite instances is accessible as. See: https://docs.djangoproject.com/en/dev/ref/settings/#std:setting-ALLOWED_HOSTS
* GRAPHITE_TIME_ZONE: (Etc/UTC) Set your local timezone
* GRAPHITE_LOG_ROTATION: (true) rotate logs
* GRAPHITE_LOG_ROTATION_COUNT: (1) number of logs to keep
* GRAPHITE_LOG_RENDERING_PERFORMANCE: (true) log performance information
* GRAPHITE_LOG_CACHE_PERFORMANCE: (true) log cache performance information
* GRAPHITE_LOG_FILE_INFO: (info.log), set to "-" for stdout/stderr
* GRAPHITE_LOG_FILE_EXCEPTION: (exception.log), set to "-" for stdout/stderr
* GRAPHITE_LOG_FILE_CACHE: (cache.log), set to "-" for stdout/stderr
* GRAPHITE_LOG_FILE_RENDERING: (rendering.log), set to "-" for stdout/stderr
* GRAPHITE_DEBUG: (false) Enable full debug page display on exceptions (Internal Server Error pages)
* GRAPHITE_DEFAULT_CACHE_DURATION: (0) Duration to cache metric data and graphs
* GRAPHITE_USE_WORKER_POOL: (true) Creates a pool of worker threads to which tasks can be dispatched
* GRAPHITE_POOL_WORKERS_PER_BACKEND: (8) The number of worker threads that should be created per backend server
* GRAPHITE_POOL_WORKERS: (1) A baseline number of workers that should always be created
* GRAPHITE_REMOTE_FIND_TIMEOUT: (30) Timeout for metric find requests
* GRAPHITE_REMOTE_FETCH_TIMEOUT: (60) Timeout to fetch series data
* GRAPHITE_MAX_FETCH_RETRIES: (2) Number of retries for a specific remote data fetch
* GRAPHITE_FIND_CACHE_DURATION: (0) Time to cache remote metric find results
* GRAPHITE_STATSD_HOST: ("") If set, django_statsd.middleware.GraphiteRequestTimingMiddleware and django_statsd.middleware.GraphiteMiddleware will be enabled.

## Building

To build the image simply checkout this repo
```
git clone https://github.com/raintank/graphite-mt.git
```
Then `cd` into the directory and run
```
make build VERSION=1.0.2
```


## Graphite local_settings.py
# Edit this file to customize the default Graphite webapp settings
#
# Additional customizations to Django settings can be added to this file as well
import os
#####################################
# General Configuration #
#####################################
#
# Set this to a long, random unique string to use as a secret key for this
# install. This key is used for salting of hashes used in auth tokens,
# CRSF middleware, cookie storage, etc. This should be set identically among
# instances if used behind a load balancer.
SECRET_KEY = os.environ.get('GRAPHITE_SECRET_KEY', "UNSAFE_DEFAULT")

# In Django 1.5+ set this to the list of hosts your graphite instances is
# accessible as. See:
# https://docs.djangoproject.com/en/dev/ref/settings/#std:setting-ALLOWED_HOSTS
ALLOWED_HOSTS = [ host.strip() for host in os.environ.get('GRAPHITE_ALLOWED_HOSTS', "*").split(",") ]

# Set your local timezone (Django's default is America/Chicago)
# If your graphs appear to be offset by a couple hours then this probably
# needs to be explicitly set to your local timezone.
TIME_ZONE = os.environ.get('GRAPHITE_TIME_ZONE', 'Etc/UTC')

# Set the default short date format. See strftime(3) for supported sequences.
#DATE_FORMAT = '%m/%d'

# Override this to provide documentation specific to your Graphite deployment
#DOCUMENTATION_URL = "http://graphite.readthedocs.io/"

# Logging
LOG_ROTATION = os.environ.get("GRAPHITE_LOG_ROTATION", "true").lower() in ['1','true','yes']
LOG_ROTATION_COUNT = int(os.environ.get('GRAPHITE_LOG_ROTATION_COUNT', '1'))
LOG_RENDERING_PERFORMANCE = os.environ.get("GRAPHITE_LOG_RENDERING_PERFORMANCE", "true").lower() in ['1','true','yes']
LOG_CACHE_PERFORMANCE = os.environ.get("GRAPHITE_LOG_CACHE_PERFORMANCE", "true").lower() in ['1','true','yes']

LOG_FILE_INFO = os.environ.get("GRAPHITE_LOG_FILE_INFO", 'info.log')
LOG_FILE_EXCEPTION = os.environ.get("GRAPHITE_LOG_FILE_EXCEPTION", 'exception.log')
LOG_FILE_CACHE = os.environ.get("GRAPHITE_LOG_FILE_CACHE", 'cache.log')
LOG_FILE_RENDERING = os.environ.get("GRAPHITE_LOG_FILE_RENDERING", 'rendering.log')

# Enable full debug page display on exceptions (Internal Server Error pages)
DEBUG = os.environ.get("GRAPHITE_DEBUG", "false").lower() in ['1','true','yes']

# Metric data and graphs are cached for one minute by default. If defined,
# DEFAULT_CACHE_POLICY is a list of tuples of minimum query time ranges mapped
# to the cache duration for the results. This allows for larger queries to be
# cached for longer periods of times. All times are in seconds. If the policy is
# empty or undefined, all results will be cached for DEFAULT_CACHE_DURATION.
DEFAULT_CACHE_DURATION = int(os.environ.get('GRAPHITE_DEFAULT_CACHE_DURATION', '0'))
 # Cache images and data for 1 minute
#DEFAULT_CACHE_POLICY = [(0, 60), # default is 60 seconds
#                        (7200, 120), # >= 2 hour queries are cached 2 minutes
#                        (21600, 180)] # >= 6 hour queries are cached 3 minutes

#####################################
# Filesystem Paths #
#####################################
#
# Change only GRAPHITE_ROOT if your install is merely shifted from /opt/graphite
# to somewhere else
GRAPHITE_ROOT = '/opt/graphite'

# Most installs done outside of a separate tree such as /opt/graphite will
# need to change these settings. Note that the default settings for each
# of these is relative to GRAPHITE_ROOT.
CONF_DIR = '/opt/graphite/conf'
STORAGE_DIR = '/opt/graphite/storage'
STATIC_ROOT = '/opt/graphite/static'
LOG_DIR = '/opt/graphite/storage/log/webapp'
INDEX_FILE = '/opt/graphite/storage/index'     # Search index file

#########################
# Cluster Configuration #
#########################
#
# To avoid excessive DNS lookups you want to stick to using IP addresses only
# in this entire section.
#

# This should list the IP address (and optionally port) of the webapp on each
# remote server in the cluster. These servers must each have local access to
# metric data. Note that the first server to return a match for a query will be
# used.
CLUSTER_SERVERS = [ host.strip() for host in os.environ.get('GRAPHITE_CLUSTER_SERVERS', "localhost:6060").split(",") ]

TAGDB = os.environ.get('GRAPHITE_TAGDB', '')
TAGDB_CACHE_DURATION = int(os.environ.get('GRAPHITE_TAGDB_CACHE_DURATION') or 60)
TAGDB_AUTOCOMPLETE_LIMIT = int(os.environ.get('GRAPHITE_TAGDB_AUTOCOMPLETE_LIMIT') or 100)

TAGDB_HTTP_URL = os.environ.get('GRAPHITE_TAGDB_HTTP_URL', '')
TAGDB_HTTP_USER = os.environ.get('GRAPHITE_TAGDB_HTTP_USER', '')
TAGDB_HTTP_PASSWORD = os.environ.get('GRAPHITE_TAGDB_HTTP_PASSWORD', '')
TAGDB_HTTP_AUTOCOMPLETE = os.environ.get('GRAPHITE_TAGDB_HTTP_AUTOCOMPLETE', 'false').lower() in ['1','true','yes']

# Creates a pool of worker threads to which tasks can be dispatched. This makes
# sense if there are multiple CLUSTER_SERVERS because then the communication
# with them can be parallelized
# The number of threads is equal to:
#   POOL_WORKERS_PER_BACKEND * len(CLUSTER_SERVERS) + POOL_WORKERS
# Be careful when increasing the number of threads, in particular if your start
# multiple graphite-web processes (with uwsgi or similar) as this will increase
# memory consumption (and number of connections to memcached).
USE_WORKER_POOL = os.environ.get("GRAPHITE_USE_WORKER_POOL", "true").lower() in ['1','true','yes']

# The number of worker threads that should be created per backend server.
# It makes sense to have more than one thread per backend server if
# the graphite-web web server itself is multi threaded and can handle multiple
# incoming requests at once.
POOL_WORKERS_PER_BACKEND = int(os.environ.get('GRAPHITE_POOL_WORKERS_PER_BACKEND', '8'))

# A baseline number of workers that should always be created, no matter how many
# cluster servers are configured. These are used for other tasks that can be
# off-loaded from the request handling threads.
POOL_WORKERS = int(os.environ.get('GRAPHITE_POOL_WORKERS', '1'))

# This setting controls whether https is used to communicate between cluster members
#INTRACLUSTER_HTTPS = False

# These are timeout values (in seconds) for requests to remote webapps
REMOTE_FIND_TIMEOUT = float(os.environ.get('GRAPHITE_REMOTE_FIND_TIMEOUT', '30'))           # Timeout for metric find requests
REMOTE_FETCH_TIMEOUT = float(os.environ.get('GRAPHITE_REMOTE_FETCH_TIMEOUT', '60'))          # Timeout to fetch series data
REMOTE_RETRY_DELAY = float(os.environ.get('GRAPHITE_REMOTE_RETRY_DELAY', '10'))           # Time before retrying a failed remote webapp

# Try to detect when a cluster server is localhost and don't forward queries
REMOTE_EXCLUDE_LOCAL = False

# Number of retries for a specific remote data fetch.
MAX_FETCH_RETRIES = int(os.environ.get('GRAPHITE_MAX_FETCH_RETRIES', '2'))

FIND_CACHE_DURATION = int(os.environ.get('GRAPHITE_FIND_CACHE_DURATION', '1'))           # Time to cache remote metric find results
# If the query doesn't fall entirely within the FIND_TOLERANCE window
# we disregard the window. This prevents unnecessary remote fetches
# caused when carbon's cache skews node.intervals, giving the appearance
# remote systems have data we don't have locally, which we probably do.
#FIND_TOLERANCE = 2 * FIND_CACHE_DURATION

REMOTE_STORE_USE_POST = True    # Use POST instead of GET for remote requests

# During a rebalance of a consistent hash cluster, after a partition event on a replication > 1 cluster,
# or in other cases we might receive multiple TimeSeries data for a metric key.  Merge them together rather
# that choosing the "most complete" one (pre-0.9.14 behaviour).
REMOTE_STORE_MERGE_RESULTS = True

# Provide a list of HTTP headers that you want forwarded on from this host
# when making a request to a remote webapp server in CLUSTER_SERVERS
REMOTE_STORE_FORWARD_HEADERS = ["x-org-id"] # An iterable of HTTP header names

## Prefetch cache
# set to True to fetch all metrics using a single http request per remote server
# instead of one http request per target, per remote server.
# Especially useful when generating graphs with more than 4-5 targets or if
# there's significant latency between this server and the backends.
REMOTE_PREFETCH_DATA = True

STORAGE_FINDERS = (
    'graphite.finders.remote.RemoteFinder',
)

STATSD_HOST = os.environ.get('GRAPHITE_STATSD_HOST', '')
if STATSD_HOST != '':
    from graphite.app_settings import *
    MIDDLEWARE = (
        'django_statsd.middleware.GraphiteRequestTimingMiddleware',
        'django_statsd.middleware.GraphiteMiddleware',
        ) + MIDDLEWARE

    try:
        MIDDLEWARE_CLASSES
    except NameError:
        pass
    else:
        MIDDLEWARE_CLASSES = MIDDLEWARE

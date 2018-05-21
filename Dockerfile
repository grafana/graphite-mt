FROM ubuntu:xenial

ARG VERSION=master

RUN apt-get update
RUN apt-get -y install \
	apache2 \
	curl \
	git \
	golang \
	libapache2-mod-wsgi \
	libcairo2 \
	libffi6 \
	libffi-dev \
	python-cffi \
	python-pip \
	python2.7

RUN pip install --upgrade pip
RUN pip install --upgrade virtualenv virtualenv-tools
RUN rm -rf /opt/graphite/*

RUN virtualenv /opt/graphite
RUN /opt/graphite/bin/pip install --no-binary=:all: https://github.com/graphite-project/graphite-web/tarball/${VERSION}
RUN /opt/graphite/bin/pip install blist
RUN /opt/graphite/bin/pip install scandir
RUN /opt/graphite/bin/pip install --no-binary=:all: https://github.com/django-statsd/django-statsd/tarball/master
RUN cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/conf/graphite.wsgi
RUN find /opt/graphite/webapp ! -perm -a+r -exec chmod a+r {} \;

RUN GOPATH=/usr go get github.com/raintank/graphite-web-proxy

COPY run.sh /
COPY local_settings.py /opt/graphite/webapp/graphite/local_settings.py
COPY vhost.conf /etc/apache2/sites-available/graphite.conf

RUN mkdir -vp /opt/graphite/run
RUN a2dissite 000-default
RUN a2ensite graphite
RUN a2enmod wsgi
RUN a2enmod headers
RUN a2enmod rewrite
RUN PYTHONPATH=/opt/graphite/webapp /opt/graphite/bin/django-admin.py collectstatic --noinput --settings=graphite.settings
RUN PYTHONPATH=/opt/graphite/webapp /opt/graphite/bin/django-admin.py migrate --settings=graphite.settings --run-syncd
RUN chown -R www-data:www-data /opt/graphite/storage

RUN apt-get -y purge \
	libffi-dev \
	git \
	golang \
	python-pip
RUN rm -rf \
	/var/lib/apt/lists/* \
	/usr/src \
	/usr/doc
RUN find / -name "*.pyc" -delete

EXPOSE 80
EXPOSE 8181

ENV \
	TSDB_KEY= \
	TSDB_URL= \
	GRAPHITE_CLUSTER_SERVERS=127.0.0.1:8181
	# GRAPHITE_ALLOWED_HOSTS= \
	# GRAPHITE_DEBUG= \
	# GRAPHITE_DEFAULT_CACHE_DURATION= \
	# GRAPHITE_FIND_CACHE_DURATION= \
	# GRAPHITE_LOG_CACHE_PERFORMANCE= \
	# GRAPHITE_LOG_RENDERING_PERFORMANCE= \
	# GRAPHITE_LOG_ROTATION= \
	# GRAPHITE_LOG_ROTATION_COUNT= \
	# GRAPHITE_MAX_FETCH_RETRIES= \
	# GRAPHITE_POOL_WORKERS= \
	# GRAPHITE_POOL_WORKERS_PER_BACKEND= \
	# GRAPHITE_REMOTE_FETCH_TIMEOUT= \
	# GRAPHITE_REMOTE_FIND_TIMEOUT= \
	# GRAPHITE_REMOTE_RETRY_DELAY= \
	# GRAPHITE_SECRET_KEY= \
	# GRAPHITE_STATSD_HOST= \
	# GRAPHITE_TIME_ZONE= \
	# GRAPHITE_USE_WORKER_POOL= \
	# WSGI_INACTIVITY_TIMEOUT= \
	# WSGI_MAX_REQUESTS= \
	# WSGI_MEMORY_LIMIT= \
	# WSGI_PROCESSES= \
	# WSGI_REQUEST_TIMEOUT= \
	# WSGI_REQUEST_TIMEOUT= \
	# WSGI_THREADS= \
	# WSGI_VIRTUAL_MEMORY_LIMIT= \
    # SINGLE_TENANT= \

HEALTHCHECK --interval=5m --timeout=10s --start-period=10s --retries=3 CMD curl https://grafana.com/api/api-keys/check -d "token=${TSDB_KEY}"

CMD ["/run.sh"]

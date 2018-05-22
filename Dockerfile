FROM alpine

RUN apk --no-cache add \
	ca-certificates \
	py2-cairo \
	py2-pip \
	py2-gunicorn
RUN apk --no-cache --virtual build-deps add \
	alpine-sdk \
	go \
	libffi-dev \
	py2-cairo-dev \
	python2-dev

RUN pip install --no-binary=:all: https://github.com/graphite-project/graphite-web/tarball/master
RUN cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/conf/graphite.wsgi
RUN find /opt/graphite/webapp ! -perm -a+r -exec chmod a+r {} \;
RUN PYTHONPATH=/opt/graphite/webapp django-admin collectstatic --noinput --settings=graphite.settings
RUN PYTHONPATH=/opt/graphite/webapp django-admin migrate --settings=graphite.settings --run-syncd
RUN mkdir -vp /opt/graphite/run
RUN ln -sv /opt/graphite/webapp/content /opt/graphite/webapp/static
RUN addgroup graphite
RUN adduser -DHh /opt/graphite -s /bin/false -G graphite graphite
RUN chown -R graphite:graphite /opt/graphite

RUN wget -O- 'https://caddyserver.com/download/linux/amd64?plugins=http.forwardproxy,http.webdav&license=personal'\
  | tar --no-same-owner -xzC /usr/bin/ caddy
RUN GOPATH=/usr go get github.com/raintank/graphite-web-proxy

RUN apk --no-cache del build-deps
RUN rm -rf \
	/usr/src \
	/usr/doc
RUN find / -name "*.pyc" -delete

ADD root /

EXPOSE 80
EXPOSE 8080
EXPOSE 8181

ENV \
	TSDB_KEY= \
	TSDB_URL= \
	GUNICORN_WORKERS=4 \
	GRAPHITE_CLUSTER_SERVERS=127.0.0.1:8181

HEALTHCHECK --interval=5m --timeout=10s --start-period=10s --retries=3 CMD curl https://grafana.com/api/api-keys/check -d "token=${TSDB_KEY}"

CMD source /run.sh

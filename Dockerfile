FROM ubuntu:focal AS build

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get -y install build-essential libffi-dev libcairo2-dev git wget python3 python3-pip apache2 curl

RUN python3 -m pip install --upgrade pip

RUN python3 -m pip install zipp \
  && python3 -m pip install --upgrade virtualenv virtualenv-tools

WORKDIR /opt/graphite
COPY .commit_sha .commit_sha

RUN python3 -m virtualenv /opt/graphite \
  && /opt/graphite/bin/pip install https://github.com/graphite-project//graphite-web/tarball/$(cat .commit_sha) \
  && /opt/graphite/bin/pip install pycairo \
  && /opt/graphite/bin/pip install https://github.com/grafana/django-statsd/tarball/master \
  && cp -r /opt/graphite/lib/python3.8/site-packages/opt/graphite/webapp/* /opt/graphite/webapp/ \
  && cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/conf/graphite.wsgi \
  && find /opt/graphite/webapp ! -perm -a+r -exec chmod a+r {} \; \
  && mkdir -p /opt/graphite/storage /opt/graphite/storage/log/webapp


FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update && apt-get -y install python3 apache2 libapache2-mod-wsgi-py3 curl libcairo2 libffi7 \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/graphite /opt/graphite
COPY run.sh /run.sh
COPY local_settings.py /opt/graphite/webapp/graphite/local_settings.py

# configure apache
COPY vhost.conf /etc/apache2/sites-available/graphite.conf
RUN a2dissite 000-default && a2ensite graphite && a2enmod wsgi && a2enmod headers && a2enmod rewrite && mkdir /opt/graphite/run

EXPOSE 80

CMD ["/run.sh"]

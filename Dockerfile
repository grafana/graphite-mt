FROM ubuntu:xenial AS build

RUN apt-get update && apt-get -y install build-essential libffi-dev libcairo2-dev git wget python2.7 python-pip apache2 curl

RUN curl -O https://bootstrap.pypa.io/pip/2.7/get-pip.py \
  && python get-pip.py

RUN pip install zipp \
  && pip install --upgrade 'virtualenv<20.0.0' virtualenv-tools

WORKDIR /opt/graphite
COPY .commit_sha .commit_sha

RUN virtualenv /opt/graphite \
  && /opt/graphite/bin/pip install --no-binary=:all: https://github.com/grafana/graphite-web/tarball/$(cat .commit_sha) \
  && /opt/graphite/bin/pip install blist \
  && /opt/graphite/bin/pip install scandir \
  && /opt/graphite/bin/pip install --no-binary=:all: https://github.com/grafana/django-statsd/tarball/master \
  && cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/conf/graphite.wsgi \
  && find /opt/graphite/webapp ! -perm -a+r -exec chmod a+r {} \;


FROM ubuntu:xenial

RUN apt-get update && apt-get -y install python2.7 apache2 libapache2-mod-wsgi curl libcairo2 libffi6 \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/graphite /opt/graphite
COPY run.sh /run.sh
COPY local_settings.py /opt/graphite/webapp/graphite/local_settings.py

# configure apache
COPY vhost.conf /etc/apache2/sites-available/graphite.conf
RUN a2dissite 000-default && a2ensite graphite && a2enmod wsgi && a2enmod headers && a2enmod rewrite && mkdir /opt/graphite/run

EXPOSE 80

CMD ["/run.sh"]

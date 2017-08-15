FROM ubuntu:xenial

MAINTAINER Anthony Woods "awoods@raintank.io"

RUN apt-get update && apt-get -y install \
	python2.7 \
	apache2 \
	libapache2-mod-wsgi \
	curl \
	libcairo2 \
	libffi6 \
&& rm -rf /var/lib/apt/lists/*

## copy graphite from build dir.
COPY build-graphite /opt/graphite
COPY run.sh /
COPY local_settings.py /opt/graphite/webapp/graphite/local_settings.py

# configure apache
COPY vhost.conf /etc/apache2/sites-available/graphite.conf
RUN a2dissite 000-default && a2ensite graphite && a2enmod wsgi && a2enmod headers && a2enmod rewrite && mkdir /opt/graphite/run

EXPOSE 80

CMD ["/run.sh"]




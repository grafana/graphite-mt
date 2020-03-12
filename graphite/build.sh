#!/bin/bash
set -x
## ensure we have build dependencies installed.
apt-get update
apt-get -y install build-essential libffi-dev libcairo2-dev git wget python2.7 python-pip apache2

pip install --upgrade pip; pip install zipp
pip install --upgrade 'virtualenv<20.0.0' virtualenv-tools

rm -rf /opt/graphite/*

VERSION=${VERSION:-master}

if [ $VERSION == "latest" ]; then
   VERSION=master
fi

virtualenv /opt/graphite
/opt/graphite/bin/pip install --no-binary=:all: https://github.com/graphite-project/graphite-web/tarball/${VERSION}
/opt/graphite/bin/pip install blist
/opt/graphite/bin/pip install scandir
/opt/graphite/bin/pip install --no-binary=:all: https://github.com/grafana/django-statsd/tarball/master

cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/conf/graphite.wsgi

find /opt/graphite/webapp ! -perm -a+r -exec chmod a+r {} \;


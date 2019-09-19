#!/bin/bash
CONFPATH="/opt/bitnami/apache2/conf/"
HTDOCSPATH="/opt/bitnami/apache2/htdocs/"

if [[ `id -u` -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

if ! [[ -d $HTDOCSPATH ]]
then
  echo $HTDOCSPATH " does not exist! Aborting..."
  exit 1
fi

if ! [[ -d $CONFPATH ]]
then
  echo $CONFPATH " does not exist! Aborting..."
  exit 1
fi

if [[ -d $HTDOCSPATH ]]
then
wget --quiet -P $HTDOCSPATH https://github.com/aworley/ocm/archive/master.zip
  unzip -qq ${HTDOCSPATH}master.zip 'ocm-master/cms/*' -d $HTDOCSPATH
  unzip -qq ${HTDOCSPATH}master.zip 'ocm-master/cms-custom/*' -d $HTDOCSPATH
  mv ${HTDOCSPATH}ocm-master/cms ${HTDOCSPATH}cms
  mv ${HTDOCSPATH}ocm-master/cms-custom ${HTDOCSPATH}cms-custom
  rm -rf ${HTDOCSPATH}ocm-master
  rm -rf ${HTDOCSPATH}master.zip
  sed -i 's/htdocs/htdocs\/cms/g' "${CONFPATH}httpd.conf"
  sed -i 's/htdocs/htdocs\/cms/g' "${CONFPATH}bitnami/bitnami.conf"
  apachectl restart
fi

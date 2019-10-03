#!/bin/bash
if [[ `id -u` -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
SUPPORTPW='password'
CONFPATH="/opt/bitnami/apache2/conf/"
HTDOCSPATH="/opt/bitnami/apache2/htdocs/"
if ! [[ -f /home/bitnami/bitnami_application_password  ]] ; then echo "The Bitnami app password file does not exist yet. Please wait a few moments and attempt to run the script again." ; exit 1 ; fi
BITNAMIPASS=$(cat /home/bitnami/bitnami_application_password)


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
#  sed -i 's/htdocs/htdocs\/cms/g' "${CONFPATH}httpd.conf"
#  sed -i 's/htdocs/htdocs\/cms/g' "${CONFPATH}bitnami/bitnami.conf"
  apachectl restart
  mysql -uroot -p${BITNAMIPASS} -e "create database cms"
  cat ${HTDOCSPATH}cms/app/sql/install/new_install.sql | mysql -uroot -p${BITNAMIPASS} cms
  sed -i "s/'db_password' => ''/'db_password' => '${BITNAMIPASS}'/" ${HTDOCSPATH}cms-custom/config/settings.php
  mysql -uroot -p${BITNAMIPASS} -e "update users set username='support', password=md5('${SUPPORTPW}')" cms
  sed -i '172,175 {s/^/\/\//}' ${HTDOCSPATH}cms/app/lib/pikaAuth.php
  rm ${HTDOCSPATH}index.html
  echo "<html><head></head><body>You have reached this page in error. Please click <a href=\"/cms/\">here</a></body></html>" > ${HTDOCSPATH}index.html
  echo -e "You can now log into your OCM instance with username support and password of \n\n"${SUPPORTPW}"\n"
  
fi

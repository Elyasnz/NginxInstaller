#!/usr/bin/env sh

# linker.sh

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

echo "linker started"
rm -rf /etc/nginx/custom-configs
ln -sf $SCRIPTPATH/custom-configs /etc/nginx/custom-configs

ln -sf $SCRIPTPATH/nginx.conf /etc/nginx/nginx.conf
ln -sf $SCRIPTPATH/sites/*.conf /etc/nginx/sites-available/
ln -sf $SCRIPTPATH/sites/*.conf /etc/nginx/sites-enabled/
ln -sf $SCRIPTPATH/ssl.crt /etc/nginx/ssl.crt
ln -sf $SCRIPTPATH/ssl.key /etc/nginx/ssl.key
ln -sf $SCRIPTPATH/modsec/bad-user-agents.txt /etc/nginx/modsec/bad-user-agents.txt
ln -sf $SCRIPTPATH/modsec/modsecurity.conf /etc/nginx/modsec/modsecurity.conf
ln -sf $SCRIPTPATH/html/* /var/www/html/


echo "linker finished"
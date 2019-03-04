#!/bin/sh

# check parameters
: "${DB_HOST:?DB_HOST needs to be set}"
: "${DB_DATABASE:?DB_DATABASE needs to be set}"
: "${DB_USERNAME:?DB_USERNAME needs to be set}"
: "${DB_PASSWORD:?DB_PASSWORD needs to be set}"
MYSQLCMDBASE="mysql --host=${DB_HOST} --port=${DB_PORT:-3306} -ns --user=${DB_USERNAME} --password=${DB_PASSWORD} --database=${DB_DATABASE}"
$MYSQLCMDBASE -w --connect-timeout=100 -e "SELECT 'OK';" ||  echo "Failed to access ${DB_HOST}:${DB_PORT:-3306}" || exit 1;
# setup for glpi
CONFFILE=/var/www/html/cacti/include/config.php.done
$MYSQLCMDBASE -w --connect-timeout=100 -e "SELECT * FROM version WHERE 1=0;"
if [ $? -gt 0 ]; then
  echo Setup data
  $MYSQLCMDBASE < cacti.sql
fi


exec $@

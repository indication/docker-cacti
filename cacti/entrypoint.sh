#!/bin/sh

# check parameters
: "${DB_HOST:?DB_HOST needs to be set}"
: "${DB_DATABASE:?DB_DATABASE needs to be set}"
: "${DB_USERNAME:?DB_USERNAME needs to be set}"
: "${DB_PASSWORD:?DB_PASSWORD needs to be set}"
: "${TZ:?TZ needs to be set}"
MYSQLCMDBASE="mysql --host=${DB_HOST} --port=${DB_PORT:-3306} -ns --user=${DB_USERNAME} --password=${DB_PASSWORD} --database=${DB_DATABASE}"

echo "date.timezone = '${TZ}'" > /usr/local/etc/php/conf.d/zzz-timezone.ini
chown www-data: -R /var/www/html/cacti

for i in `seq 1 20`
do
  $MYSQLCMDBASE -w --connect-timeout=1000 -e "SELECT 'OK';"
  if [ $? -eq 0 ]; then
    break
  fi
  if [ $i -eq 10 ]; then
    echo "Failed to access ${DB_HOST}:${DB_PORT:-3306}"
    exit 1
  fi
  sleep 1
done
# setup for cacti
CONFFILE=/var/www/html/cacti/include/config.php.done
$MYSQLCMDBASE -w --connect-timeout=1000 -e "SELECT * FROM version WHERE 1=0;"
if [ $? -gt 0 ]; then
  echo Setup data
  $MYSQLCMDBASE < /var/www/html/cacti/cacti.sql
fi
SPINE_CONF=/etc/spine.conf
if [ ! -f "$SPINE_CONF" ]; then
  echo Create spine config
  echo "# spine config" > $SPINE_CONF
  echo "DB_Host       ${DB_HOST}" >> $SPINE_CONF
  echo "DB_Database   ${DB_DATABASE}" >> $SPINE_CONF
  echo "DB_User       ${DB_USERNAME}" >> $SPINE_CONF
  echo "DB_Pass       ${DB_PASSWORD}" >> $SPINE_CONF
  echo "DB_Port       ${DB_PORT:-3306}" >> $SPINE_CONF
  echo "RDB_Host      ${DB_HOST}" >> $SPINE_CONF
  echo "RDB_Database  ${DB_DATABASE}" >> $SPINE_CONF
  echo "RDB_User      ${DB_USERNAME}" >> $SPINE_CONF
  echo "RDB_Pass      ${DB_PASSWORD}" >> $SPINE_CONF
  echo "RDB_Port      ${DB_PORT:-3306}" >> $SPINE_CONF
fi


exec $@

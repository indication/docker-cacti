#!bin/sh

MYSQL_CONFD=/etc/mysql/mysql.conf.d
MYSQL_CONFD_LOCAL=/tmp/zzz-cacti.cnf
echo "[mysqld]" > $MYSQL_CONFD_LOCAL
echo "innodb_read_io_threads=32" >> $MYSQL_CONFD_LOCAL
echo "innodb_write_io_threads=16" >> $MYSQL_CONFD_LOCAL
echo "innodb_flush_log_at_timeout=3" >> $MYSQL_CONFD_LOCAL
echo "max_allowed_packet=16777216" >> $MYSQL_CONFD_LOCAL
mv $MYSQL_CONFD_LOCAL $MYSQL_CONFD/

CREATE DATABASE cacti;
create user 'cacti'@'%' identified by 'cactipass';
grant all on cacti.* to 'cacti'@'%';
grant select on mysql.time_zone_name to 'cacti'@'%';
FLUSH PRIVILEGES;

CREATE DATABASE cacti;
create user 'cacti'@'%' identified by 'cactipass';
grant all on cacti.* to 'cacti'@'%';
FLUSH PRIVILEGES;


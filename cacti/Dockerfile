FROM php:7.2-fpm-alpine

MAINTAINER in_dow <in_dow [at] hotmail.com>

################### SETUP PACKAGES  ########################
# Install recommend packages
RUN apk add -U --no-cache mysql-client net-snmp \
    rrdtool libzip \
    h2o supervisor sudo
# Setup additional packages
RUN set -ex \
    && apk add -U --no-cache --virtual .php-buildapps gcc make perl autoconf file g++ \
        dpkg-dev dpkg re2c patch libc-dev net-snmp-dev \
    && docker-php-ext-install -j$(nproc) mysqli pdo_mysql \
    && docker-php-ext-install -j$(nproc) snmp opcache \
    && pecl install apcu \
    && pecl clear-cache \
    && apk del --purge .php-buildapps \
    && mkdir -p /var/www/html/cacti /usr/local/spine/bin/


###################### DATA VOLUME  ########################
VOLUME ["/var/lib/glpi"]

############ INITIAL APPLICATION SETUP #####################
# DO NOT change the order of following commands
WORKDIR /var/www/html/cacti
RUN chown -R www-data:www-data /var/www/html /usr/local/spine/bin
USER www-data
ENV CACTI_VERSION 1.2.2
ENV CACTI_MD5SUM 67763be07bfeaf142f771fe306eaba5c
ENV SPINE_MD5SUM 6c84af65180f45d6d2cbe74b41f07c74
# Clone and dependencies
# Copy all configuration files and add alias(ln) to /cacti
RUN set -ex \
    && curl -o /tmp/cacti.tar.gz -sSL https://github.com/Cacti/cacti/archive/release/$CACTI_VERSION.tar.gz \
    && md5sum /tmp/cacti.tar.gz \
    && (echo "$CACTI_MD5SUM */tmp/cacti.tar.gz" | md5sum -c || (md5sum /tmp/cacti.tar.gz && exit 1)) \
    && tar -xzf /tmp/cacti.tar.gz --strip-components=1 \
    && cat include/config.php.dist \
       | sed -re 's#(database_hostname\s*= )[^;]+#\1 getenv("DB_HOST")#' \
       | sed -re 's#(database_username\s*= )[^;]+#\1 getenv("DB_USERNAME")#' \
       | sed -re 's#(database_password\s*= )[^;]+#\1 getenv("DB_PASSWORD")#' \
       | sed -re 's#(database_default\s*= )[^;]+#\1 getenv("DB_DATABASE")#' \
       | sed -re 's#(database_port\s*= )[^;]+#\1 getenv("DB_PORT") == "" ? "3306" : getenv("DB_PORT")#' \
       > include/config.php \
    && rm include/config.php.dist \
    && rm /tmp/cacti.tar.gz
    
USER root
# setup plugins
RUN set -ex \
    && apk add -U --no-cache --virtual .spine-buildapps gcc make automake dos2unix autoconf gzip file m4 \
        patch libc-dev net-snmp-dev libtool mariadb-dev help2man \
    && curl -o /tmp/spine.tar.gz -sSL https://github.com/Cacti/spine/archive/release/$CACTI_VERSION.tar.gz \
    && (echo "$SPINE_MD5SUM */tmp/spine.tar.gz" | md5sum -c || (md5sum /tmp/spine.tar.gz && exit 1)) \
    && mkdir -p spine \
    && cd spine \
    && tar -xzf /tmp/spine.tar.gz --strip-components=1 \
    && ./bootstrap \
    && ./configure \
    && make -j$(nproc) -s \
    && make install \
    && cd .. \
    && rm -rf /tmp/spine.tar.gz spine \
    && apk del --purge .spine-buildapps


####################### SERVER SETUP #######################
EXPOSE 80

# Setup H2O and supervisor and entrypoint
COPY supervisord.conf \
     h2o.conf \
     zzz-www.conf \
     entrypoint.sh \
     /tmp/
RUN set -ex \
      && echo "*/5    *       *       *       *       php /var/www/html/glpi/front/cron.php >& /dev/null" > crond.txt \
      && echo "*/5    *       *       *       *       /var/www/html/glpi/bin/console glpi:ldap:synchronize_users  | grep -v 'No active LDAP server found.'" >> crond.txt \
      && echo "*/5    *       *       *       *       /var/www/html/glpi/plugins/ocsinventoryng/scripts/ocsng_fullsync.sh --thread_nbr=2 " >> crond.txt \
      && echo "*/5    *       *       *       *       /var/www/html/glpi/plugins/ocsinventoryng/scripts/ocsng_snmpfullsync.sh --thread_nbr=2 " >> crond.txt \
      && cat crond.txt | crontab -u www-data - && rm crond.txt \
      && mv /tmp/supervisord.conf /tmp/h2o.conf /etc/ \
      && chmod 644 /etc/supervisord.conf /etc/h2o.conf \
      && mv /tmp/zzz-www.conf /usr/local/etc/php-fpm.d/ \
      && mkdir -p /var/run/php-fpm \
      && chown www-data:www-data /var/run/php-fpm \
      && mv /tmp/entrypoint.sh / \
      && chmod +x /entrypoint.sh

# Put entry point to execute
ENTRYPOINT ["/entrypoint.sh"]

# Startup supervisor
CMD ["supervisord", "-c", "/etc/supervisord.conf"]

FROM 382797964672.dkr.ecr.us-east-1.amazonaws.com/php5.6-apache

RUN docker-php-ext-install mysqli && \
    docker-php-ext-install pdo && \
    docker-php-ext-install pdo_mysql

RUN a2enmod rewrite

RUN apt-get update \
&& apt-get install -y \
unzip wget git libz-dev libmemcached-dev libmemcached11 libmemcachedutil2 build-essential libzip-dev zip \
&& pecl install memcached-2.2.0 \
&& echo extension=memcached.so >> /usr/local/etc/php/conf.d/memcached.ini

RUN docker-php-ext-configure zip --with-libzip \
&& docker-php-ext-install zip

RUN docker-php-ext-enable opcache

RUN apt-get update && \
apt-get install -y libfreetype6-dev libjpeg62-turbo-dev && \
docker-php-ext-install mbstring && \
docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/  &&  \
docker-php-ext-install gd

# no anda esto, darle permiso localmente para que funcione.
#RUN chmod -R 777 /var/www/html/appserver/protected/runtime
#RUN chmod -R 777 /var/www/html/appserver/protected/data
#RUN echo "max_execution_time = 300" >> /usr/local/etc/php/php.ini

WORKDIR /var/www/html

RUN git clone https://github.com/yiisoft/yii.git /var/www/yii

COPY index-prod.php /var/www/html/appserver/index.php
COPY . /var/www/html/appserver

ADD https://kickads-appserver-resources.s3.amazonaws.com/DB19-IP-COUNTRY-REGION-CITY-LATITUDE-LONGITUDE-ISP-DOMAIN-MOBILE.BIN.ZIP DB19.ZIP
RUN unzip DB19.ZIP -d /var/www/html/appserver/protected/data
RUN mv /var/www/html/appserver/protected/data/IP-COUNTRY-REGION-CITY-LATITUDE-LONGITUDE-ISP-DOMAIN-MOBILE.BIN /var/www/html/appserver/protected/data/ip2location.BIN
RUN rm DB19.ZIP

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && ls -al /var/www/html
RUN chown -R www-data:www-data /var/www/yii \
    && chmod -R 755 /var/www/yii \
    && ls -al /var/www/yii

# COPY yii /var/www

COPY vh.conf /etc/apache2/sites-available/000-default.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN apt-get \
remove -y git build-essential libmemcached-dev libz-dev unzip \
&& apt-get autoremove -y \
&& apt-get clean \
&& rm -rf /tmp/pear

EXPOSE 80

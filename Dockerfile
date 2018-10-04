FROM ubuntu 

LABEL Description="ieptb/php"
MAINTAINER ieptb/php
#DEPENDENCIAS
RUN apt-get update -y
RUN apt-cache search gnupg
RUN apt-get install gnupg -y
RUN apt-get upgrade -y
RUN apt-get install -y tzdata
ENV TZ "America/Sao_Paulo"
RUN echo "America/Sao_Paulo" > /etc/timezone \
&& dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get install -y git curl apache2 php libapache2-mod-php php-mysql php-xml php-zip php-gd
RUN rm -f /etc/localtime
RUN ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get install msodbcsql17 apt-utils -y
RUN apt-get install unixodbc-dev -y
RUN apt-get install php7.2 php-dev php-xml php-pear php7.2-odbc php7.2-mbstring php7.2-curl php7.2-soap php-mongodb -y
RUN apt-get install composer -y
RUN pecl install sqlsrv
RUN pecl install pdo_sqlsrv
RUN echo extension=pdo_sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-pdo_sqlsrv.ini
RUN echo extension=sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/20-sqlsrv.ini
RUN a2dismod mpm_event
RUN a2enmod mpm_prefork
RUN a2enmod php7.2
RUN echo "extension=sqlsrv.so" >> /etc/php/7.2/apache2/php.ini
RUN echo "extension=pdo_sqlsrv.so" >> /etc/php/7.2/apache2/php.ini
RUN service apache2 restart

#INSTALAR APLICACAO

RUN rm -rf /var/www/html/*
RUN rm -f /etc/apache2/sites-available/000-default.conf
ADD 000-default.conf /etc/apache2/sites-available/

#Configuracao APACHE 

RUN a2enmod rewrite
RUN chown -R www-data:www-data /var/www/html/
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ADD run.sh ./
ADD 20-sqlsrv.ini /etc/php/7.2/apache2/conf.d/
ADD 30-pdo_sqlsrv.ini /etc/php/7.2/apache2/conf.d/
RUN a2enmod php7.2
RUN service apache2 restart
RUN chmod a+rx /run.sh

EXPOSE 80
CMD ["/bin/bash", "/run.sh"]
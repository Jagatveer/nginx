FROM centos:6.6

MAINTAINER Jagatveer Singh <jagatveer@hotmail.com>

ENV NGINX_VERSION 1.11.3
ENV OPENSSL_VERSION 1.0.2h
ENV php_conf /etc/php.ini
ENV PREFIX /usr/local/nginx

ENV config "\
          --prefix=/usr/local/nginx \
          --without-mail_pop3_module \
          --user=nobody \
          --group=nobody \
          --with-http_ssl_module \
          --with-openssl=/usr/src/openssl-1.0.2h \
          --without-mail_imap_module \
          --without-mail_smtp_module \
          --lock-path=/var/lock/nginx.lock \
          --pid-path=/var/run/nginx.pid \
          --with-http_stub_status_module \
          --with-pcre \
          --with-http_spdy_module \
          --with-libdir=lib64 \
          --with-config-file-path=/etc/ \
          --with-config-file-scan-dir=/usr/lib64/php/module \
          --with-pear \
          --enable-cli \
          --enable-intl \
          --enable-bcmath \
          --disable-cgi \
          --enable-fpm \
          --with-zlib \
          --with-kerberos \
          --with-bz2 \
          --with-curl \
          --enable-ftp \
          --enable-zip \
          --enable-exif \
          --with-gd \
          --with-jpeg-dir=/usr/lib64 \
          --with-freetype-dir=/usr/lib64 \
          --enable-gd-native-ttf \
          --with-gettext \
          --with-gmp \
          --with-mhash \
          --with-iconv \
          --with-mysql \
          --with-imap \
          --with-imap-ssl \
          --enable-sockets \
          --enable-soap \
          --with-xmlrpc \
          --with-mcrypt \
          --enable-mbstring \
          --enable-embedded-mysqli \
          --with-mysqli=mysqlnd \
          --with-mysql-sock \
          --with-sqlite3 \
          --with-pdo-mysql \
          --with-pdo-mysql=mysqlnd \
          --with-pdo-sqlite \
          --enable-phar \
          --enable-pcntl \"

RUN \
          rpm -ivh https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm \
          && yum clean all \
          && yum check \
          && yum erase apf \
          && yum upgrade -y \
          && yum install wget tar gcc make curl pcre-devel openssl openssl-devel -y

RUN \
          groupadd nginx \
          && id -u nginx &>/dev/null || useradd -s /sbin/nologin nginx -g nginx \
          && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
          && mkdir -p /usr/src \
          && tar -zxC /usr/src -f nginx.tar.gz \
          && wget https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz -O openssl.tar.gz \
          && tar -zxC /usr/src -f openssl.tar.gz \
          && rm nginx.tar.gz openssl.tar.gz \
          && cd /usr/src/nginx-$NGINX_VERSION \
          && ./configure $CONFIG \
        	&& make \
        	&& make install \
          && mkdir -p $PREFIX/vhosts.d \
          && mkdir -p $PREFIX/upstream.d \
          && mkdir -p $PREFIX/disabled.d \
          && mkdir -p $PREFIX/proxies.d \
          && mkdir -p /var/www/html/error_pages \
          && chown -R nginx:nginx /var/www/html

COPY conf/nginx.conf /usr/local/nginx/conf/nginx.conf
COPY conf/nginx /etc/init.d/nginx
COPY conf/index.html /var/www/html/index.html
COPY conf/500.html /var/www/html/error_pages/500.html
COPY conf/404.html /var/www/html/error_pages/404.html

EXPOSE 80 443
CMD ["start", "--foreground", "nginx"]

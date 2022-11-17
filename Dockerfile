#for php 5.6
FROM php:5.6-apache

#php5.6 use ver2.0.8 php > 7 able to use ver 3.2.7
ENV igBinaryVersion="2.0.8"
#php5.6 use ver2.2.8 php > 7 able to use ver 5.3.7
ENV redisVersion="2.2.8"

RUN buildDeps=" \
    libmcrypt-dev \
    libcurl4-gnutls-dev \
    libicu-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    libc-client-dev \
    libssh2-1-dev \
    libbz2-dev \
    libgpgme11-dev \
    redis-server \
    git \
    nano \
    " \
    && apt-get update && apt-get install -y $buildDeps \
    && pecl install ssh2 gnupg \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) bcmath bz2 calendar gd intl mcrypt mysqli opcache pdo_mysql soap sockets xmlrpc zip \
    && docker-php-ext-enable intl ssh2 gnupg \
    && a2enmod rewrite

# Install php-igbinary
RUN mkdir -p /usr/src/php/ext/igbinary \
    && curl -fsSL https://github.com/igbinary/igbinary/archive/$igBinaryVersion.tar.gz | tar xvz -C /usr/src/php/ext/igbinary --strip 1 \
    && docker-php-ext-install igbinary
    # && rm igbinary-$redisVersion.tar.gz

# Install php-redis
RUN mkdir -p /usr/src/php/ext/redis \
    && curl -fsSL https://github.com/phpredis/phpredis/archive/$redisVersion.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && docker-php-ext-configure redis --enable-redis-igbinary \
    && docker-php-ext-install redis
    # && rm phpredis-$redisVersion.tar.gz

# Install composer and put binary into $PATH
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/ \
    && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

# Copy custom config files
ADD ./config/php.ini /usr/local/etc/php/conf.d/custom-config.ini
COPY ./config/000-default.conf /etc/apache2/sites-available/000-default.conf

# Clean system
RUN apt-get purge -y $buildDeps \
    && apt-get autoremove -y \
    && rm -rf /tmp/* /var/tmp/* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

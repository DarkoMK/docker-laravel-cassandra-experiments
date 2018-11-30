FROM php:7.1.6-fpm

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl wget libssl-dev zlib1g-dev \
    libicu-dev g++ make cmake libgmp-dev \
    uuid-dev automake cmake g++ pkg-config \
    libtool apt-utils libssl-dev openssl libssl-dev

RUN wget downloads.datastax.com/cpp-driver/ubuntu/14.04/dependencies/libuv/v1.8.0/libuv_1.8.0-1_amd64.deb
RUN wget downloads.datastax.com/cpp-driver/ubuntu/14.04/dependencies/libuv/v1.8.0/libuv-dev_1.8.0-1_amd64.deb
RUN wget downloads.datastax.com/cpp-driver/ubuntu/14.04/cassandra/v2.7.1/cassandra-cpp-driver_2.7.1-1_amd64.deb
RUN wget downloads.datastax.com/cpp-driver/ubuntu/14.04/cassandra/v2.7.1/cassandra-cpp-driver-dev_2.7.1-1_amd64.deb

RUN dpkg -i libuv_1.8.0-1_amd64.deb
RUN dpkg -i libuv-dev_1.8.0-1_amd64.deb
RUN dpkg -i cassandra-cpp-driver_2.7.1-1_amd64.deb
RUN dpkg -i cassandra-cpp-driver-dev_2.7.1-1_amd64.deb

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install datastax php-driver fox cassandra
RUN pecl install cassandra \
    && docker-php-ext-enable cassandra

# Install extensions
RUN docker-php-ext-install mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
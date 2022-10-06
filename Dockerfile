# Arguments defined in docker-compose.yml
# ARG NODE_VERSION
ARG PHP_VERSION

# FROM node:${NODE_VERSION} AS node
FROM php:${PHP_VERSION}-fpm

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/public/

# Copy package-lock.json and package.json
# COPY package-lock.json package.json /var/www/

# Set working directory
WORKDIR /var/www/public

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfontconfig1 \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libxrender1 \
    libzip-dev \
    locales \
    jpegoptim optipng pngquant gifsicle \
    # python \
    # python2 \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring exif bcmath pcntl gd zip

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy nodejs
# COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
# COPY --from=node /usr/local/bin/node /usr/local/bin/node
# RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www/public

# Install dependencies
RUN composer install
# RUN npm install --global node-gyp && npm rebuild node-sass
# RUN npm install

# Clean the image
RUN apt-get remove -qq -y pkg-config build-essential \
    # libmagickwand-dev \
    && apt-get auto-remove -qq -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy existing application directory permissions
COPY --chown=www:www . /var/www/public

# Change current user to www
USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]

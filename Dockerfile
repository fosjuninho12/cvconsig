FROM php:7.4-apache

# Instala dependências do sistema
RUN apt-get update && apt-get install -y \
    git unzip libzip-dev \
    libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql zip gd \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Configura DocumentRoot (raiz do projeto)
ENV APACHE_DOCUMENT_ROOT /var/www/html

# Atualiza configs do Apache
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copia o projeto
WORKDIR /var/www/html
COPY . /var/www/html

# .htaccess (renomear se necessário)
RUN if [ -f htaccess.txt ]; then mv htaccess.txt .htaccess; fi

# Instala dependências PHP
RUN composer install --no-dev --optimize-autoloader || true

# Permissões
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE 80

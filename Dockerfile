FROM php:8.4.5-cli-alpine3.21

RUN apk add --no-cache --virtual .build-deps \
    icu-data-full \
    gettext \
    gettext-dev \
    libintl \
    postgresql-dev \
    sqlite \
    && docker-php-ext-install -j$(nproc) \
    gettext \
    intl \
    mysqli \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    && rm -rf /var/cache/apk/*

WORKDIR /app

COPY . .

RUN mkdir -p /db /app/inc

RUN sqlite3 /db/pdns.db < /app/sql/pdns/47/schema.sqlite3.sql
RUN sqlite3 /db/pdns.db < /app/sql/poweradmin-sqlite-db-structure.sql
RUN rm -rf /app/sql

#RUN echo '<?php' > /app/inc/config.inc.php
#RUN echo '$db_type="sqlite";' >> /app/inc/config.inc.php
#RUN echo '$db_file="/db/pdns.db";' >> /app/inc/config.inc.php

#RUN php -r 'echo bin2hex(random_bytes(32));' > /tmp/session_key.txt
#RUN echo "\$session_key=\"$(cat /tmp/session_key.txt)\";" >> /app/inc/config.inc.php

RUN chown -R www-data:www-data /db /app \
    && chmod -R 755 /db /app


RUN rm -fr /app/install

USER www-data

EXPOSE 80

ENTRYPOINT ["php", "-S", "0.0.0.0:80", "-t", "/app"]

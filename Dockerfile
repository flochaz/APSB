FROM tutum/apache-php
MAINTAINER Florian CHAZAL <florianchazal@gmail.com>

# Install mysql-client and git
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        mysql-client \
        unzip \
        lftp \
    && rm -rf /var/lib/apt/lists/*

# Install wp-cli, configure Apache
WORKDIR /app
RUN curl \
        -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp \
    && sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf \
    && a2enmod rewrite \
    && service apache2 restart

# Get theme updated code 
COPY wp-content wp-content

# Get backed up db
COPY data /data

COPY run.sh /run.sh
COPY deploy.sh /deploy.sh

RUN chmod +x /run.sh /deploy.sh


# Run the server
EXPOSE 80 443
CMD ["/run.sh"]

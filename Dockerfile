FROM r-base:latest

RUN apt-get update -y \
	&& apt-get install -y --no-install-recommends \
		libmariadb-client-lgpl-dev

RUN apt-get update -y && \
      apt-get -y install \
      apache2 \
      libapache2-mod-php \
      php && \
    apt-get clean && rm -r /var/lib/apt/lists/*

# Apache + PHP requires preforking Apache for best results & enable Apache SSL
# forward request and error logs to docker log collector
RUN a2dismod mpm_event && \
    a2enmod mpm_prefork \
            ssl \
            rewrite && \
    a2ensite default-ssl && \
    ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

WORKDIR /var/www/html

EXPOSE 80

COPY ./html/* /var/www/html/
# COPY ./config/php.ini /etc/php5/apache2/

RUN Rscript install.R
RUN rm /var/www/html/index.html

RUN chmod +x apache2-foreground
CMD ["./apache2-foreground"]
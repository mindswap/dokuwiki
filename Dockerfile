FROM ubuntu:trusty
MAINTAINER MindSwap <mindswap@ro.ru>

RUN apt-get update && \
    apt-get install -y supervisor nginx php5-fpm php5-gd curl unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
ENV DOKUWIKI_VERSION 2017-02-19a
ENV MD5_CHECKSUM 78e8c27291fbc3de04c7f107c3f7725a

RUN mkdir -p /var/www /var/www/lib/plugins/ /var/dokuwiki-storage/data &&  \
    cd /var/www && \
    curl -O "http://download.dokuwiki.org/src/dokuwiki/dokuwiki-$DOKUWIKI_VERSION.tgz" && \
    echo "$MD5_CHECKSUM  dokuwiki-$DOKUWIKI_VERSION.tgz" | md5sum -c - && \
    tar xzf "dokuwiki-$DOKUWIKI_VERSION.tgz" --strip 1 && \
    rm "dokuwiki-$DOKUWIKI_VERSION.tgz" && \
    mv /var/www/data/pages /var/dokuwiki-storage/data/pages && \
    ln -s /var/dokuwiki-storage/data/pages /var/www/data/pages && \
    mv /var/www/data/meta /var/dokuwiki-storage/data/meta && \
    ln -s /var/dokuwiki-storage/data/meta /var/www/data/meta && \
    mv /var/www/data/media /var/dokuwiki-storage/data/media && \
    ln -s /var/dokuwiki-storage/data/media /var/www/data/media && \
    mv /var/www/data/media_attic /var/dokuwiki-storage/data/media_attic && \
    ln -s /var/dokuwiki-storage/data/media_attic /var/www/data/media_attic && \
    mv /var/www/data/media_meta /var/dokuwiki-storage/data/media_meta && \
    ln -s /var/dokuwiki-storage/data/media_meta /var/www/data/media_meta && \
    mv /var/www/data/attic /var/dokuwiki-storage/data/attic && \
    ln -s /var/dokuwiki-storage/data/attic /var/www/data/attic && \
    mv /var/www/conf /var/dokuwiki-storage/conf && \
    ln -s /var/dokuwiki-storage/conf /var/www/conf

RUN curl -O -L "https://github.com/selfthinker/dokuwiki_plugin_wrap/archive/stable.zip" && \
    unzip stable.zip -d /var/www/lib/plugins/ && \
    mv /var/www/lib/plugins/dokuwiki_plugin_wrap-stable/ /var/www/lib/plugins/wrap/ && \
    rm -rf stable.zip

RUN curl -O -L "http://www.heiko-barth.de/downloads/dw_codebutton.zip" && \
    unzip dw_codebutton.zip -d /var/www/lib/plugins/ && \
    rm -rf dw_codebutton.zip
    
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/*
ADD dokuwiki.conf /etc/nginx/sites-enabled/    
    
ADD supervisord.conf /etc/supervisord.conf
ADD start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 80
VOLUME ["/var/dokuwiki-storage"]

CMD /start.sh

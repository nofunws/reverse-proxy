FROM debian:testing

MAINTAINER Alexander Shevchenko <kudato@me.com>

ENV DEBIAN_FRONTEND noninteractive
ENV HTTP 80
ENV HTTPS 443
ENV FQDN example.com
ENV EMAIL support@storage.ws
ENV DESTINATION localhost:8000

RUN apt-get update && apt-get -y upgrade && apt-get install -y locales supervisor && \
    touch /etc/supervisor/conf.d/supervisord.conf && \
    echo "[supervisord]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisor/conf.d/supervisord.conf && \
	mv /etc/localtime  /etc/localtime-old && \
	ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime

ADD https /https
ADD http /http
ADD le.sh /le.sh
ADD entrypoint.sh /entrypoint.sh

RUN apt-get install -y nginx letsencrypt && \
	echo "[program:nginx]" >> /etc/supervisor/conf.d/supervisord.conf && \
	echo "command = /usr/sbin/nginx" >> /etc/supervisor/conf.d/supervisord.conf && \
	echo "user = root" >> /etc/supervisor/conf.d/supervisord.conf && \
	echo "autostart = true" >> /etc/supervisor/conf.d/supervisord.conf && \
	rm -rf /etc/nginx/sites-enabled/default && rm -rf /etc/nginx/nginx.conf && \
	mkdir -p /etc/nginx/ssl && mkdir -p /usr/share/nginx/html
ADD nginx.conf /etc/nginx/nginx.conf

RUN chmod +x /*.sh
# - >
CMD ["/entrypoint.sh"]

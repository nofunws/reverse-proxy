#!/bin/sh

HTTPS_CONFIG=/etc/nginx/sites-enabled/https
HTTP_CONFIG=/etc/nginx/sites-enabled/http

setup_nginx_le () {
	# make dhparams
	if [ ! -f /etc/nginx/ssl/dhparams.pem ]; then
    	echo "make dhparams"
    	cd /etc/nginx/ssl
    	openssl dhparam -out dhparams.pem 2048
    	chmod 600 dhparams.pem
	fi
	sed -i "s|FQDN|${FQDN}|g" /http
	sed -i "s|HTTP|${HTTP}|g" /http
	sed -i "s|FQDN|${FQDN}|g" /https
	sed -i "s|HTTPS|${HTTPS}|g" /https
	sed -i "s|DESTINATION|${DESTINATION}|g" /https
	(
 		while :
 		do
 		if [ ! -f $HTTPS_CONFIG ]; then
 			if [ ! -f $HTTP_CONFIG ]; then
	 			mv /http $HTTP_CONFIG
	 		fi
 			nginx -s reload
 			sleep 3
 			/le.sh && mv /https $HTTPS_CONFIG && \
 			nginx -s reload
 			sleep 60d
 		else
 			if [ ! -f $HTTP_CONFIG ]; then
	 			mv /http $HTTP_CONFIG
	 		fi
 			mv $HTTPS_CONFIG /https
			nginx -s reload
 			sleep 3
 			/le.sh && mv /https $HTTPS_CONFIG && \
 			nginx -s reload
 			sleep 60d
 		fi
 		done
	) &
}
# -
if [ ! -f /etc/nginx/ssl/ssl.crt ]; then
	setup_nginx_le
fi
# -
/usr/bin/supervisord
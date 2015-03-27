np_setup() {

	chmod +x /usr/local/np-cli/np && ln -s /usr/local/np-cli/np /usr/bin/np

	# ------------------------
	# INSTALL
	# ------------------------
	
	apk-install supervisor \
	            openssl \
	            nginx \
	            php-fpm \
                php-opcache \
                php-mcrypt \
                php-curl \
                php-zlib \
                php-pdo \
                php-gd \
                php-gettext \
                php-mysql \
                php-xml \
                php-zip
                
	# ------------------------
	# NP USER
	# ------------------------
		
 	adduser -G nginx -h $home -D npuser
 	echo "source /etc/environment" >> $home/.bashrc
  	chown root:root $home && chmod 755 $home

	mkdir -p $home/www
	mkdir -p $home/ssl
	mkdir -p $home/run
		
	# ------------------------
	# CONFIG
	# ------------------------

	cat $nps/etc/html/index.html > $home/www/index.html
	cat $nps/etc/html/info.php > $home/www/info.php
	
	cat $nps/etc/nginx/nginx.conf > /etc/nginx/nginx.conf
	cat $nps/etc/nginx/default.conf > /etc/nginx/default.conf
	cat $nps/etc/php/php-fpm.conf > /etc/php/php-fpm.conf
	cat $nps/etc/supervisord.conf > /etc/supervisord.conf

	cat > $home/run/nginx.ini <<'EOF'
[program:nginx]
command = /usr/sbin/nginx -c /etc/nginx/nginx.conf
EOF
	cat > $home/run/php-fpm.ini <<'EOF'
[program:php-fpm]
command = /usr/bin/php-fpm -c /etc/php/php.ini -y /etc/php/php-fpm.conf
EOF

	# ------------------------
	# SSL CERT.
	# ------------------------
	
	cd $home/ssl
	
	cat $nps/etc/nginx/openssl.conf > openssl.conf

	openssl req -nodes -sha256 -newkey rsa:2048 -keyout app.key -out app.csr -config openssl.conf -batch
	openssl rsa -in app.key -out app.key
	openssl x509 -req -days 365 -sha256 -in app.csr -signkey app.key -out app.crt

	rm -f openssl.conf
	
	# ------------------------
	# FIX PERMISSIONS
	# ------------------------

	chown npuser:nginx -R $home/* && chmod 755 -R $home/*
}

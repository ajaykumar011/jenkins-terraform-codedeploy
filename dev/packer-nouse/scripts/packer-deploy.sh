#!/bin/bash -xe
set -e
#exec > >(tee /tmp/packer-script.log|logger -t packer-script -s 2>/dev/console) 2>&1

mv /tmp/app /var/www/app

chown -R $USER:www-data /var/www && chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \; 
find /var/www -type f -exec chmod 0664 {} \; 

#Log permission
chown -R $USER:www-data /var/log/nginx/
chown -R $USER:www-data /var/lib/php/sessions

echo 'user ubuntu;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;
events {
        worker_connections 768;
}
http {
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        include /etc/nginx/mime.types;
        default_type application/octet-stream;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;
        gzip on;
        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;
}' > /etc/nginx/nginx.conf || echo 'Nginx.conf Writing Failed'

echo 'server {
        listen 80 default_server;
        root /var/www/app;
        index index.php index.html;
        server_name _;

        location / {
                #try_files $uri $uri/ =404;
	              try_files $uri $uri/ /index.php?q=$uri&$args;      
	              }

        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
        }

        location ~ /\.ht {
                deny all;
        }
}' > /etc/nginx/sites-available/default || echo 'Nginx.conf Writing Failed'

nginx -t || { echo 'Syntax Error.. Nginx Failed' ; exit 1; }

#PHP Settings part
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/7.3/fpm/php.ini
sed -i 's/user = www-data/user = ubuntu/g' /etc/php/7.3/fpm/pool.d/www.conf
sed -i 's/listen.owner = www-data/listen.owner = ubuntu/g' /etc/php/7.3/fpm/pool.d/www.conf

#service restart
systemctl restart nginx 
systemctl restart php7.3-fpm  
systemctl restart mysql 

#cleanup
rm -rf /tmp/*


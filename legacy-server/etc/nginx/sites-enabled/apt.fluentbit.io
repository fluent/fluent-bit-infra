server {

	root /var/www/apt.fluentbit.io;
	index index.html index.htm index.nginx-debian.html;

	server_name apt.fluentbit.io packages.fluentbit.io;
	access_log /var/log/nginx/apt.fluentbit.io.access.log;
	error_log  /var/log/nginx/apt.fluentbit.io.error.log;

	location / {
		try_files $uri $uri/ =404;
	}

    listen [::]:443 ssl; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/fluentbit.io/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/fluentbit.io/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot


}
server {
    if ($host = packages.fluentbit.io) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    if ($host = apt.fluentbit.io) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


	listen 80;
	listen [::]:80;

	server_name apt.fluentbit.io packages.fluentbit.io;
    return 404; # managed by Certbot




}

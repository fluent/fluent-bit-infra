server {

	root /var/www/releases.fluentbit.io/releases;
	index index.html index.htm index.nginx-debian.html;

	server_name releases.fluentbit.io;
	access_log /var/log/nginx/releases.fluentbit.io.access.log;
	error_log  /var/log/nginx/releases.fluentbit.io.error.log;

	location / {
		try_files $uri $uri/ =404;
                autoindex on;
	}

    listen [::]:443 ssl; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/fluentbit.io/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/fluentbit.io/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot


}
server {
    if ($host = releases.fluentbit.io) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


	listen 80;
	listen [::]:80;

	server_name releases.fluentbit.io;
    return 404; # managed by Certbot




}

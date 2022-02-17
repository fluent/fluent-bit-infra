server {

	root /var/www/fluentbit-website;
	index index.html index.htm index.nginx-debian.html;

        server_name legacy.fluentbit.io www-old.fluentbit.io;

	access_log /var/log/nginx/fluentbit.io.access.log;
	error_log  /var/log/nginx/fluentbit.io.error.log;

	location / {
		try_files $uri $uri/ =404;
	}

        location ~/documentation/0.12/* {
		return 301 https://docs.fluentbit.io/manual/;
	}

    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/fluentbit.io/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/fluentbit.io/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot


}
server {
    if ($host = legacy.fluentbit.io) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    if ($host = www-old.fluentbit.io) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


	listen 80;
	listen [::]:80;

	server_name legacy.fluentbit.io www-old.fluentbit.io;
        return 404; # managed by Certbot




}

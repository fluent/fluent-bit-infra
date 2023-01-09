#!/bin/sh
set -eu
mkdir -p /var/www/apt.fluentbit.io /var/www/releases.fluentbit.io


# Set up the package serving
cat > /etc/nginx/sites-available/apt.fluentbit.io <<'EOF'
server {
	root /var/www/apt.fluentbit.io;
	index index.html index.htm index.nginx-debian.html;

	server_name apt.fluentbit.io packages.fluentbit.io;
	access_log /var/log/nginx/apt.fluentbit.io.access.log;
	error_log  /var/log/nginx/apt.fluentbit.io.error.log;

	location / {
		try_files $uri $uri/ =404;
		autoindex on;
	}

	listen 80;
	listen [::]:80;
}
EOF
ln -s /etc/nginx/sites-available/apt-fluentbit.io /etc/nginx/sites-enabled/apt-fluentbit.io

# Set up the releases handling - Windows + Source/JSON
cat > /etc/nginx/sites-available/releases.fluentbit.io <<'EOF'
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

	listen 80;
	listen [::]:80;
}
EOF
ln -s /etc/nginx/sites-available/releases-fluentbit.io /etc/nginx/sites-enabled/releases-fluentbit.io
systemctl restart nginx

# TODO: certificates from certbot
# snap install core
# snap refresh core
# snap install --classic certbot
# ln -s /snap/bin/certbot /usr/bin/certbot
# certbot --nginx # -d packages.fluentbit.io -d www.packages.fluentbit.io
# systemctl restart nginx

# Ensure firewall is allowing traffic
# if command -v ufw > /dev/null 2>&1; then
#     ufw allow 'Nginx Full'
#     ufw delete allow 'Nginx HTTP'
#     ufw status
# fi

# Set up sync
aws s3 sync s3://fluentbit-releases /var/www/apt.fluentbit.io --no-sign-request

# Set up cron job
cat > /etc/systemd/system/packages-sync.service <<EOF
[Unit]
Description=Syncs all release packages from the AWS bucket to this server.
Wants=packages-sync.timer

[Service]
Type=oneshot
ExecStart=aws s3 sync s3://fluentbit-releases /var/www/apt.fluentbit.io --no-sign-request

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/packages-sync.timer <<EOF
[Unit]
Description=Syncs all release packages from the AWS bucket to this server.
Requires=packages-sync.service

[Timer]
Unit=packages-sync.service
OnCalendar=*-*-* *:00:00

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now packages-sync.timer

mkdir -p /opt/fluent-bit-stats
git clone https://github.com/niedbalski/fluent-bit-stats.git /opt/fluent-bit-stats
( cd /opt/fluent-bit-stats; docker compose up -d )

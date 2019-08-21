#!/usr/bin/env bash

echo Hello! How many wordpress sites do you want to make?
read SITE_COUNT
while ! [[ "${SITE_COUNT}" =~ ^[1-5]+$ ]] 
do
  echo Please enter a number between 1 to 5.
  SITE_COUNT=""
  read SITE_COUNT
done

echo "Setting up for ${SITE_COUNT} sites..."
for i in `seq 1 $SITE_COUNT`
do
  echo Please enter a Fully Qualified Domain Name for site number $i
  read DOMAIN_NAME
  while ! [[ $DOMAIN_NAME == $(echo $DOMAIN_NAME | grep -P '(?=^.{1,254}$)(^(?>(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)') ]] || [[ $DOMAIN_NAME == "" ]]
  do
    echo Invalid FQDN. Please try again.
    DOMAIN_NAME=""
    read DOMAIN_NAME
  done
  DOMAIN_ARRAY[${#DOMAIN_ARRAY[@]}]=$DOMAIN_NAME
done

if test -f "docker-compose.production.yml"
then
  rm docker-compose.production.yml
  touch docker-compose.production.yml
fi
cat > docker-compose.production.yml <<EOF
version: '3.7'

services:
EOF

if test -f "nginx.conf"
then
  rm nginx.conf
  touch nginx.conf
fi

for domain in "${DOMAIN_ARRAY[@]}"
do
  MYSQL_PASSWORD=`openssl rand -base64 10`
  MYSQL_ROOT_PASSWORD=`openssl rand -base64 10`
  cat >> docker-compose.production.yml <<EOF
  db-${domain}:
    image: mysql:5.7
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: "${domain}-db"
      MYSQL_USER: "${domain}-dbuser"
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - ./db-${domain}:/var/lib/mysql

  wp-${domain}:
    image: wordpress:5-fpm
    restart: always
    volumes:
      - ./php-uploads.ini:/usr/local/etc/php/conf.d/uploads.ini
    depends_on:
      - db-${domain}
    environment:
      WORDPRESS_DB_HOST: db-${domain}:3306
      WORDPRESS_DB_USER: "${domain}-dbuser"
      WORDPRESS_DB_PASSWORD: ${MYSQL_PASSWORD}
      WORDPRESS_DB_NAME: "${domain}-db"
    working_dir: /var/www/html/wp-${domain}
    volumes:
      - ./wp-${domain}:/var/www/html/wp-${domain}

EOF

  cat >> nginx.conf <<EOF
server {
  listen 80;
  server_name ${domain};

  root /var/www/html/wp-${domain};
  index index.php;

  access_log /var/log/nginx/access.log;
  error_log /var/log/nginx/error.log;

  client_max_body_size 64M;

  location / {
      try_files \$uri \$uri/ /index.php?\$args;
  }

  location ~ \.php$ {
      try_files \$uri =404;
      fastcgi_split_path_info ^(.+\.php)(/.+)\$;
      fastcgi_pass wp-${domain}:9000;
      fastcgi_index index.php;
      include fastcgi_params;
      fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
      fastcgi_param PATH_INFO \$fastcgi_path_info;
  }
}

EOF
done

# nginx portion
cat >> docker-compose.production.yml <<EOF
  web:
    depends_on:
EOF
for domain in "${DOMAIN_ARRAY[@]}"
do
  cat >> docker-compose.production.yml <<EOF
      - wp-${domain}
EOF
done

cat >> docker-compose.production.yml <<EOF
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
EOF
for domain in "${DOMAIN_ARRAY[@]}"
do
  cat >> docker-compose.production.yml <<EOF
      - ./logs-${domain}:/var/log/nginx/wp-${domain}
      - ./wp-${domain}:/var/www/html/wp-${domain}
EOF
done

cat >> docker-compose.production.yml <<EOF
    ports:
      - 80:80
EOF

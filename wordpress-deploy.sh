#!/bin/bash
clear

# 1 Your script will check if PHP, Mysql & Nginx are installed. If not present, missing packages will be installed.
# 2 The script will then ask user for domain name. (Suppose user enters example.com)
# 3 Create a /etc/hosts entry for example.com pointing to localhost IP.
# 4 Create nginx config file for example.com
# 5 Download WordPress latest version from http://wordpress.org/latest.zip and unzip it locally in example.com document root.
# 6 Create a new mysql database for new WordPress. (database name “example.com_db” )
# 7 Create wp-config.php with proper DB configuration. (You can use wp-config-sample.php as your template)
# 8 You may need to fix file permissions, cleanup temporary files, restart or reload nginx config.
# 9 Tell user to open example.com in browser (if all goes well)

# 1 - checking (L)EMP
# 	Referencing https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-in-ubuntu-16-04 for LEMP install
# 	https://stackoverflow.com/questions/1951506/add-a-new-element-to-an-array-without-specifying-the-index-in-bash

# 	for colors I referenced: https://stackoverflow.com/a/5947802/8606026
red="\033[0;31m"
green='\033[0;32m' white='\033[1;37m'
blue_back="\033[44m"
inverse="\033[7m"
nc="\033[0m" # No Color

echo -e "Welcome to Neal's semi-automated ${blue_back}${white}WordPress${nc} deployment script!!!";
if [[ $EUID > 0 ]]
  then echo -e "${red}Please run as root/sudo${nc}"
  exit
fi

required_packages=(nginx mysql-server php-fpm php-mysql php-curl php-gd php-mbstring php-mcrypt php-xml php-xmlrpc)
to_install=()
for package in ${required_packages[@]}
do
	if dpkg -s $package >/dev/null >/dev/null 2>&1; then
		echo -e "${green}$package${nc} is installed"
	else
		if [$package="mysql-server"]; then
			database_root_pass=$(openssl rand -base64 14)
			debconf-set-selections <<< "mysql-server mysql-server/root_password password $database_root_pass"
			debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $database_root_pass"
		fi
		echo -e "${red}$package${nc} will be installed"
		to_install+=($package)
	fi
done

# 	Get the latest package lists
echo -e "${inverse}running apt-get update for latest package list${nc}"
apt-get update

# 	now install needed packages
echo -e "Installing: ${inverse}${to_install[@]}${nc}"
apt-get install -y ${to_install[@]}

# 2 - ask user for domain
echo -e "${inverse}Enter domain for new blog (ex: example.com):${nc}"
read domain

#3 - create entry in /etc/hosts
echo "127.0.0.1 $domain" >> /etc/hosts

#4 - create nginx config for domain
cat > /etc/nginx/sites-available/$domain.conf <<EOL
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/$domain;
    index index.php index.html index.htm index.nginx-debian.html;

    server_name server_domain_or_IP;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/$domain.conf /etc/nginx/sites-enabled/

#5 - download WordPress (we will move it to /var/www/$domain below 7 because I want to finish the wp-config.php setup
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
rm latest.tar.gz

# 6 Create a new mysql database for new WordPress. (database name “example.com_db” )
database_name="${domain}_db"
database_user="${domain}_wpu"
database_pass=$(openssl rand -base64 14)

create_db_query="CREATE DATABASE $database_name;"
echo -e "${inverse}Database Root Pass=$database_root_pass${nc}"
mysql -uroot -p$database_root_password -e "$create_db_query"
create_user_query="GRANT ALL PRIVILEGES ON $database_name.* TO $database_user@localhost IDENTIFIED BY '$database_pass';"
mysql -uroot -p$database_root_password -e "$create_user_query"

# 7 Create wp-config.php with proper DB configuration. (You can use wp-config-sample.php as your template)
cp wordpress/wp-config-sample.php wordpress/wp-config.php
sed -i -e "s/database_name_here/${database_name}/g" wordpress/wp-config.php
sed -i -e "s/username_here/${database_user}/g" wordpress/wp-config.php
sed -i -e "s/password_here/${database_pass}/g" wordpress/wp-config.php
#	might as well update the salts

# 	now move wordpress/ to /var/www/$domain
mv wordpress/ /var/www/$domain

echo "install complete"
echo "mysql root pass: $database_root_pass"
#mysql_secure_installation
echo -e "${inverse}${red}Please run mysql_secure_installation asap${nc}"
# 	there are several ways to get local machine's public ip i like sed and for DO Droplets works fine
#	another option may be: ip route get 8.8.8.8 | head -1 | cut -d' ' -f8
# 	both IP options are discussed here: https://stackoverflow.com/a/13322549/8606026 and https://stackoverflow.com/a/25851186/8606026
public_ip=$(curl -s http://whatismyip.akamai.com/)
/etc/init.d/nginx reload
echo -e "${inverse}You can now visit http://$public_ip${nc}"
#TODO add scripted SSL support

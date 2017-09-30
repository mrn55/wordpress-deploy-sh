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
# Referencing https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-in-ubuntu-16-04 for LEMP install
# https://stackoverflow.com/questions/1951506/add-a-new-element-to-an-array-without-specifying-the-index-in-bash

# for colors I referenced: https://stackoverflow.com/a/5947802/8606026
RED="\033[0;31m"
GREEN='\033[0;32m'
WHITE='\033[1;37m'
BLUE_BACK="\033[44m"
INVERSE="\033[7m"
NC="\033[0m" # No Color

echo -e "Welcome to Neal's semi-automated ${BLUE_BACK}${WHITE}WordPress${NC} deployment script!!!";
if [[ $EUID > 0 ]]
  then echo -e "${RED}Please run as root/sudo${NC}"
  exit
fi

REQUIRED_PACKAGES=(nginx mysql-server php-fpm php-mysql php-curl php-gd php-mbstring php-mcrypt php-xml php-xmlrpc)
TO_INSTALL=()
for package in ${REQUIRED_PACKAGES[@]}
do
	if dpkg -s $package >/dev/null >/dev/null 2>&1; then
		echo -e "${GREEN}$package${NC} is installed"
	else
		echo -e "${RED}$package${NC} will be installed"
		TO_INSTALL+=($package)
	fi
done

# Get the latest package lists
echo -e "${INVERSE}running apt-get update for latest package list${NC}"
apt-get update

echo "Installing: ${TO_INSTALL[@]}"
apt-get install -y ${TO_INSTALL[@]}

# 2 - ask user for domain
echo -e "${INVERSE}Enter domain for new blog (ex: example.com):${NC}"
read domain

#3 - create entry in /etc/hosts
echo "127.0.0.1 $domain" >> /etc/hosts

#4 - create nginx config for domain

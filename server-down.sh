service mysql stop
service nginx stop
service php-fpm stop

# ask user for domain
echo -e "${inverse}Enter domain for new blog (ex: example.com):${nc}"
read domain

rm -rf /var/www/$domain/
rm /etc/nginx/sites-enabled/$domain.conf
rm /etc/nginx/sites-avalible/$domain.conf

killall -KILL mysql mysqld_safe mysqld nginx php-fpm
apt-get --yes purge mysql-server mysql-client nginx php-fpm php-mysql php-curl php-gd php-mbstring php-mcrypt php-xml php-xmlrpc
apt-get --yes autoremove --purge
apt-get autoclean
deluser --remove-home mysql
delgroup mysql
rm -rf /etc/apparmor.d/abstractions/mysql /etc/apparmor.d/cache/usr.sbin.mysqld /etc/mysql /var/lib/mysql /var/log/mysql* /var/log/upstart/mysql.log* /var/run/mysqld
updatedb

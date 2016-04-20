#!/bin/bash
sudo apt-get update > /dev/null

echo ">>>>>>>>>>>>>>>>>>> Running bootstrap.sh <<<<<<<<<<<<<<<<<<"

#install mysql
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root' > /dev/null
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root' > /dev/null
sudo apt-get install -y mysql-server > /dev/null

sudo apt-get install -y apache2 php5 libapache2-mod-php5 curl php5-mysql php5-cli php5-curl php5-mysql php5-intl sqlite3 libsqlite3-dev php5-sqlite > /dev/null

echo "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf
sudo a2enmod rewrite > /dev/null

sudo cp /vagrant/apache2/vhost.conf /etc/apache2/sites-available/000-default.conf
sudo sed -i 's/bind-address/;bind-address/g' /etc/mysql/my.cnf
sudo sed -i 's/skip-external-locking/;skip-external-locking/g' /etc/mysql/my.cnf

mysql -uroot -proot -e "GRANT ALL ON *.* to root@'%' IDENTIFIED BY 'root'; FLUSH PRIVILEGES;"

sudo rm -rf /var/www/html

sudo service apache2 restart
sudo service mysql restart

curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

echo "alias s='php /var/www/bin/console'" | sudo tee ~/.bashrc

cd /var/www

composer install -o

echo '----- CREATE DATABASE -----'

#s doctrine:database:create
#php app/console doctrine:schema:update --force --em=reference
#php app/console doctrine:fixtures:load --fixtures=src/Billercentral/ContractBundle/DataFixtures/LiveReferenceDatabase --em=reference
#
#php app/console doctrine:database:create --connection=central
#php app/console doctrine:schema:update --force --em=central
#php app/console doctrine:fixtures:load --fixtures=src/Billercentral/AuthBundle --em=central
#
#php app/console billercentral:companies:create test 00000
#php app/console billercentral:users:create user userpass test
#php app/console doctrine:fixtures:load --fixtures=src/Billercentral/ContractBundle/DataFixtures/ORM --em=user


sudo apt-get -y install php-pear php5-dev php5-xdebug
sudo pecl -y install xdebug

echo "
zend_extension=/usr/lib/php5/20090626+lfs/xdebug.so
[xdebug]
xdebug.remote_enable=1
xdebug.remote_host=10.0.2.15
xdebug.remote_port=9000
xdebug.profiler_enable = on
xdebug.remote_connect_back=1
xdebug.profiler_enable_trigger = on" >> /etc/php5/apache2/php.ini

sudo service apache2 restart

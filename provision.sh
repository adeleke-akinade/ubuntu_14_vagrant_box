#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='root'

# update / upgrade
sudo apt-get update
sudo apt-get -y upgrade

# install apache 2.5 and php 5.6
sudo apt-get install -y apache2
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install -y php5.6
sudo apt-get install -y php5.6-zip

# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mysql-server
sudo apt-get install -y php5-mysql

# setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
	ServerName localhost.dev
    DocumentRoot "/var/www"
    <Directory "/var/www">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
<VirtualHost *:80>
	ServerName watermark.dev
	ServerAlias www.watermark.dev
    DocumentRoot "/var/www/watermark"
    <Directory "/var/www/watermark">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf

# enable mod_rewrite
sudo a2enmod rewrite

# restart apache
service apache2 restart

# install git
sudo apt-get -y install git

# install Composer
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
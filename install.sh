sudo apt-get update

# configure mysql
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

# use latest PHP
sudo apt-get install -y vim curl python-software-properties
sudo add-apt-repository -y ppa:ondrej/php5
sudo apt-get update

sudo apt-get install -y php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt php5-readline mysql-server-5.5 php5-mysql git-core php5-xdebug

# for testing in sqlite in memory databases
sudo apt-get install -y sqlite3 php5-sqlite

# for the ability to create pdf files
sudo apt-get install -y libxrender-dev

# apt-get install -y beanstalkd supervisor 

# Xdebug
cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

# enable php error reporting
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini
sed -i "s/disable_functions = .*/disable_functions = /" /etc/php5/cli/php.ini

# Apache
# ------
# Setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
  DocumentRoot "/var/www/public"
  <Directory "/var/www/public">
    Options -Indexes +FollowSymLinks
    AllowOverride All
    Require all granted
  </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-enabled/000-default.conf
# Enable mod_rewrite
a2enmod rewrite
# Restart apache
sudo service apache2 restart

# install composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# SSL Certificate
# ------
# sudo make-ssl-cert generate-default-snakeoil --force-overwrite
# sudo a2enmod ssl
# sudo a2ensite default-ssl.conf
# sudo service apache2 reload

# # Laravel stuff
# # -------------
# # Load Composer packages
# cd /var/www
# composer install --dev
# # Set up the database
# mysql -u root --password=root <<QUERY_INPUT
# CREATE DATABASE IF NOT EXISTS database;
# QUERY_INPUT
# #echo "CREATE DATABASE IF NOT EXISTS easycampaign" | mysql
# #echo "CREATE USER 'root'@'localhost' IDENTIFIED BY 'root'" | mysql
# #echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'root'" | mysql
# # Run artisan migrate to setup the database and schema, then seed it
# php artisan migrate --env=development
# php artisan db:seed --env=development

# # additional stuff
# sudo service beanstalkd start

# SUPERVISORCONFIG=$(cat <<EOF
# [program:queue]
# command=php artisan queue:listen --tries=2
# directory=/var/www
# stdout_logfile=/var/www/app/storage/logs/supervisor.log
# redirect_stderr=true
# EOF
# )
# echo "${SUPERVISORCONFIG}" > /etc/supervisor/conf.d/queue.conf



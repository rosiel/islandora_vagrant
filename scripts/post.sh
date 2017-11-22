#!/bin/bash

# Setup a user for Tomcat Manager
sed -i '$i<role rolename="admin-gui"/>' /etc/tomcat7/tomcat-users.xml
sed -i '$i<user username="islandora" password="islandora" roles="manager-gui,admin-gui"/>' /etc/tomcat7/tomcat-users.xml
service tomcat7 restart

# Set correct permissions on sites/default/files
chmod -R 775 /var/www/drupal/sites/default/files

# Allow anonymous & authenticated users to view repository objects
drush --root=/var/www/drupal role-add-perm "anonymous user" "view fedora repository objects"
drush --root=/var/www/drupal role-add-perm "authenticated user" "view fedora repository objects"
drush --root=/var/www/drupal cc all

# Update Drupal and friends to something recent
drush --root=/var/www/drupal -v -y pm-update

# Add useful modules
drush --root=/var/www/drupal -v -y en admin_menu module_filter views_ui
drush --root=/var/www/drupal -v -y pm-disable toolbar

# Add xdebug
sudo apt-get install php5-xdebug
cat <<'EOT' >> /etc/php5/apache2/php.ini
[XDebug]
zend_extension=/usr/lib/php5/20121212/xdebug.so
xdebug.remote_enable=on
xdebug.remote_handler=dbgp
xdebug.remote_host=localhost:8000
xdebug.remote_port=9000
xdebug.remote_connect_back=1
EOT
sudo service apache2 restart

# Copy all drupal files into /vagrant shared folder.
cp -r /var/www/drupal /vagrant

cp /vagrant/scripts/update_modules.sh /vagrant/drupal/sites/all/modules/

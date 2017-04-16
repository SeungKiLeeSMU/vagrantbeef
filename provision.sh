#!/bin/bash

mysql_config_file="/etc/mysql/my.cnf"

main() {
    apt-get update
    setup_apache
    setup_mysql
    setup_php
    setup_misc
}

setup_apache() {
    apt-get -y install apache2

    # Set up virtualhost
    cat << EOF > /etc/apache2/sites-available/beef.conf
<VirtualHost *:80>
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html/frontend

	Alias /api /var/www/html/backend
	<Directory /var/www/html/backend>
		Options All
		AllowOverride All
		order allow,deny
		allow from all
	</Directory>

	ErrorLog /var/log/apache2/error.log
	CustomLog /var/log/apache2/access.log combined
</VirtualHost>
EOF

    a2dissite 000-default
    a2ensite beef
    systemctl restart apache2

    # Make dirs for frontend and backend

    mkdir /var/www/html/frontend
    mkdir /var/www/html/backend
    echo 'frontbeef' > /var/www/html/frontend/index.html
    echo '<?php echo "backbeef"; ?>' > /var/www/html/backend/index.php
    sudo chown -R ubuntu /var/www/html/
}

setup_mysql() {
    echo "mysql-server mysql-server/root_password password root" | \
        debconf-set-selections
    echo "mysql-server mysql-server/root_password_again password root" | \
        debconf-set-selections
    apt-get -y install mysql-client mysql-server

    sed -i "s/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" \
        ${mysql_config_file}

    # Allow root access from any host
    echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION" | mysql -u root --password=root
    echo "GRANT PROXY ON ''@'' TO 'root'@'%' WITH GRANT OPTION" | mysql -u root --password=root

    if [ -d "/vagrant/provision-sql" ]; then
        echo "Executing all SQL files in /vagrant/provision-sql folder ..."
        echo "-------------------------------------"
        for sql_file in /vagrant/provision-sql/*.sql
        do
            echo "EXECUTING $sql_file..."
            time mysql -u root --password=root < $sql_file
            echo "FINISHED $sql_file"
            echo ""
        done
    fi

    systemctl mysql restart
}

setup_php () {
    apt-get -y install php php-cli libapache2-mod-php php-mysql php-mcrypt
    systemctl restart apache2

	# Install latest version of Composer globally
	if [ ! -f "/usr/local/bin/composer" ]; then
		curl -sS https://getcomposer.org/installer | \
            php -- --install-dir=/usr/local/bin --filename=composer
	fi
}

setup_misc () {
    apt-get -y install curl git
}

main

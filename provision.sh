#!/bin/bash

mysql_config_file="/etc/mysql/my.cnf"
php_config_file="/etc/php5/apache2/php.ini"

main() {
    apt-get update
    setup_apache
    setup_mysql
    setup_php
    setup_misc
}

setup_apache() {
    apt-get -y install apache2
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
}

setup_misc () {
    apt-get -y install curl git
}

main

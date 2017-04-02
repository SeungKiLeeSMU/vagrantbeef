# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"

  # Forward ports to Apache and MySQL
  config.vm.network "forwarded_port", guest: 80, host: 8888
  config.vm.network "forwarded_port", guest: 3306, host: 8889

  # share web root
  config.vm.synced_folder "./html", "/var/www/html"

  config.vm.provision "shell", path: "provision.sh"
end

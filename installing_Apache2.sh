#!/bin/bash

function installing_apache2_ubuntu() {
	sudo apt-get update
	sudo apt-get install apache2
	sudo systemctl start apache2
	sudo systemctl status apache2
}

function installing_apache2_centOS() {
	sudo yum update httpd # packages are updated
	sudo yum install httpd # install the Apache package
	sudo firewall-cmd --permanent --add-service=http 
	#install firewall on my server and open port 80 
	# to allow Apache to serve requests over HTTP.
	sudo firewall-cmd --permanent --add-service=https
	# open port 443 by enabling the https service
	sudo firewall-cmd --reload
	# reload the firewall to put these new rules into effect
	sudo systemctl start httpd 
	sudo systemctl status httpd 
	# checking your Web Server	
}

if cat /etc/os-release | grep "Ubuntu"; then
	installing_apache2_ubuntu
fi


if cat /etc/os-release | grep "CentOS"; then
	installing_apache2_centOS
fi

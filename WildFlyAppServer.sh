# update the system
sudo apt update && sudo apt upgrade -y 

# install openJDK 11 JDK
sudo apt install openjdk-11-jdk -y

#install Apache http server
sudo apt install apache2 -y

# перевіряємо чи є така штука /opt/wildfly/
sudo ls /opt/wildfly/

#download and unpack WildFly distribution
wget https://download.jboss.org/wildfly/24.0.1.Final/wildfly-24.0.1.Final.tar.gz
tar xf wildfly-24.0.1.Final.tar.gz
sudo mv wildfly-24.0.1.Final /opt/wildfly

# Create a new user and group for WildFly service
sudo useradd --system --no-create-home --user-group wildfly

# Change the owner of /opt/wildfly directory to the wildfly user and group
sudo chown -R wildfly:wildfly /opt/wildfly

# Create a configuration file for the WildFly service
sudo bash -c 'cat > /etc/systemd/system/wildfly.service << EOF
[Unit]
Description=The WildFly Application Server
After=syslog.target network.target

[Service]
User=wildfly
Group=wildfly
ExecStart=/opt/wildfly/bin/standalone.sh -b=0.0.0.0
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF'

# отримаємо ту саму конфігурацію
sudo cat etc/systemd/system/wildfly.service

# Reload the systemd system configuration
sudo systemctl daemon-reload

# Start the WildFly service
sudo systemctl start wildfly

# Enable the WildFly service to start on boot
sudo systemctl enable wildfly

# Create a directory for private key and certificate
sudo mkdir /etc/apache2/ssl

# Generate self-signed SSL certificate and private key
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt

# Configure Apache to use SSL

# додаю конфіг на те, щоб був редирект з 80 порта,
# на якому працю Apache на порт 8080 як по http,
# так і по https трафіку.

sudo bash -c 'cat > /etc/apache2/sites-available/000-default.conf << EOF
<VirtualHost *:80>
   ServerName localhost
   Redirect / https://localhost/
</VirtualHost>

<VirtualHost *:443>
   SSLEngine on
   SSLCertificateFile /etc/apache2/ssl/apache.crt
   SSLCertificateKeyFile /etc/apache2/ssl/apache.key

   ProxyRequests Off
   ProxyPreserveHost On
   ProxyPass / http://localhost:8080/
   ProxyPassReverse / http://localhost:8080/
</VirtualHost>
EOF'

# Enable the SSL and proxy modules

sudo a2enmod ssl
sudo a2enmod proxy
sudo a2enmod proxy_http

# Restart Apache to implement changes
sudo systemctl restart apache2

# Configure WildFly to use the correct IP address
sudo sed -i 's/<inet-address value="${jboss.bind.address.management:127.0.0.1}"/<inet-address value="${jboss.bind.address.management:0.0.0.0}"/g' /opt/wildfly/standalone/configuration/standalone.xml
sudo sed -i 's/<inet-address value="${jboss.bind.address:127.0.0.1}"/<inet-address value="${jboss.bind.address:0.0.0.0}"/g' /opt/wildfly/standalone/configuration/standalone.xml

# Restart the WildFly service
sudo systemctl restart wildfly

# НАЧАЛОСЬ !!!
sudo apt-get install git 
git clone https://github.com/Diliri/DevOps.git
cd git-homework/DevOps/
./mvnw package # cтягує залежності з Maven central-у
cd target/
ll
mv devops-1.0-SNAPSHOT.war app.war
sudo cp app.war /opt/wildfly/standalone/deployments/


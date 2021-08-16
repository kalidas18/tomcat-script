#!/bin/bash
#===================================================================================
#
# FILE: tomcat-install-script.sh
#
# USAGE: ./tomcat-install-script-auto deployment
#
# DESCRIPTION: 
#            After running the script you need to create tomcat user accounts with proper roles to use this in a developer enviorenment. 
#            This script only install tomcat server as a service on your linux system.
#	    
#
# CREATED BY : Hariharaprasath
#
#
# COMPANY: TechMango
#
# VERSION: 1.0
#
# CREATED: 23-Feb-2021 - 04:30 AM IST
# 
# 

############################################################################################################################################
TIME=$(date +"%Y-%m-%d-%H%M")
hostname=`hostname -f`
ip=`hostname -I | awk '{print $1}'

# Check if user has root privileges
if [[ $EUID -ne 0 ]]; then
echo "You must run the script as root or using sudo"
   exit 1
fi


#groupadd tomcat && useradd -M -s /bin/nologin -g tomcat -d /usr/local/tomcat tomcat
function check_java_home {
if [ -z ${JAVA_HOME} ]
    then
        echo 'Could not find JAVA_HOME. Please install Java and set JAVA_HOME'
        echo ' Downloading the java application'
cd /usr/local/
wget --header 'Cookie: oraclelicense=a' http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jre-8u131-linux-x64.tar.gz
tar -xf jre-8u131-linux-x64.tar.gz && rm -f jre-8u131-linux-x64.tar.gz
mv jre1.8.0_131 java
else 
	echo 'JAVA_HOME found: '$JAVA_HOME
      
        fi
   
}

echo 'Installing tomcat server...'
echo 'Checking for JAVA_HOME...'
check_java_home
 
echo 'JAVA_HOME=/usr/local/java
export JAVA_HOME
PATH=$PATH:$JAVA_HOME/bin
export PATH' >> /etc/profile
 
source /etc/profile
java -version

 
cd /opt/
wget wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.0.M10/bin/apache-tomcat-9.0.0.M10.tar.gz
tar -xvf apache-tomcat-9.0.0.M10.tar.gz
mv apache-tomcat-9.0.0.M10 tomcat
rm -f apache-tomcat-9.0.0.M10.tar.gz

cd /opt/tomcat
chgrp -R tomcat conf
chmod g+rwx conf
chmod g+r conf/*
chown -R sys-user webapps/ work/ temp/ logs/
chown -R sys-user:sys-user *
chown -R sys-user:sys-user /opt/tomcat



echo '# Systemd unit file for tomcat
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/local/java
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/bin/kill -15 $MAINPID

User=sys-user
Group=sys-user

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/tomcat.service
 
 
systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat

echo "check the url responce'
curl --head $http:\\$ip:8080
## Open in web browser:
## http://server_IP_address:8080

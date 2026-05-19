#! /bin/bash
cd /opt/
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.6.50800.zip
unzip sonarqube-8.9.6.50800.zip
sudo dnf install java-17-amazon-corretto -y
useradd sonar
chown sonar:sonar sonarqube-8.9.6.50800 -R
chmod 777 sonarqube-8.9.6.50800 -R
su - sonar
# use the below command manually after installation
#sh /opt/sonarqube-8.9.6.50800/bin/linux-x86-64/sonar.sh start
#echo "user=admin & password=admin"


#Latest SonarQube installation Script.

#!/bin/bash

cd /opt/

# Get latest stable SonarQube version dynamically (or pin a specific one)
# SonarQube 8.9.x requires Java 11, but 9.x+ requires Java 17
# Using a current LTS version
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.8.100196.zip

unzip sonarqube-9.9.8.100196.zip

# Install Java 17 (required for SonarQube 9.x+)
dnf install java-17-amazon-corretto -y

# Set JAVA_HOME
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))

# Create sonar user (no login shell for security)
useradd -m -d /opt/sonarqube-9.9.8.100196 -s /bin/bash sonar

# Set correct ownership
chown -R sonar:sonar /opt/sonarqube-9.9.8.100196

# 777 is too open, 755 is correct for security
chmod -R 755 /opt/sonarqube-9.9.8.100196

# Required kernel settings for SonarQube (Elasticsearch needs these)
echo "vm.max_map_count=524288" >> /etc/sysctl.conf
echo "fs.file-max=131072" >> /etc/sysctl.conf
sysctl -p

# Set ulimits for sonar user
echo "sonar   -   nofile   131072" >> /etc/security/limits.conf
echo "sonar   -   nproc    8192" >> /etc/security/limits.conf

# Start SonarQube as sonar user
su - sonar -c "sh /opt/sonarqube-9.9.8.100196/bin/linux-x86-64/sonar.sh start"

echo "SonarQube started! Access at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9000"
echo "Default credentials: user=admin, password=admin"

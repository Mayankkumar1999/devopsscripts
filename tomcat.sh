dnf install java-21-amazon-corretto -y
wget https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.14/bin/apache-tomcat-11.0.14.tar.gz
tar -zxvf apache-tomcat-11.0.14.tar.gz
sed -i '56  a\<role rolename="manager-gui"/>' apache-tomcat-11.0.14/conf/tomcat-users.xml
sed -i '57  a\<role rolename="manager-script"/>' apache-tomcat-11.0.14/conf/tomcat-users.xml
sed -i '58  a\<user username="tomcat" password="root123456" roles="manager-gui, manager-script"/>' apache-tomcat-11.0.14/conf/tomcat-users.xml
sed -i '59  a\</tomcat-users>' apache-tomcat-11.0.14/conf/tomcat-users.xml
sed -i '56d' apache-tomcat-11.0.14/conf/tomcat-users.xml
sed -i '21d' apache-tomcat-11.0.14/webapps/manager/META-INF/context.xml
sed -i '22d' apache-tomcat-11.0.14/webapps/manager/META-INF/context.xml
sh apache-tomcat-11.0.14/bin/startup.sh



#bin this is another script for downloading tomcat

#!/bin/bash

# Install Java 21
dnf install java-21-amazon-corretto -y

# Set JAVA_HOME
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))

# Get latest Tomcat 11 version dynamically
VERSION=$(curl -s https://dlcdn.apache.org/tomcat/tomcat-11/ | grep -oP '(?<=v)[\d.]+' | sort -V | tail -1)
echo "Installing Tomcat version: $VERSION"

# Download Tomcat
wget https://dlcdn.apache.org/tomcat/tomcat-11/v${VERSION}/bin/apache-tomcat-${VERSION}.tar.gz

# Extract
tar -zxvf apache-tomcat-${VERSION}.tar.gz

# Configure tomcat-users.xml safely
sed -i 's|</tomcat-users>|<role rolename="manager-gui"/>\n<role rolename="manager-script"/>\n<user username="tomcat" password="root123456" roles="manager-gui,manager-script"/>\n</tomcat-users>|' apache-tomcat-${VERSION}/conf/tomcat-users.xml

# Fix context.xml - rewrite completely without IP restriction
cat > apache-tomcat-${VERSION}/webapps/manager/META-INF/context.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true" ignoreAnnotations="true">
  <CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor"
                   sameSiteCookies="strict" />
  <Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$LruCache(?:\$1)?|java\.util\.(?:Linked)?HashMap"/>
</Context>
EOF

# Start Tomcat
sh apache-tomcat-${VERSION}/bin/startup.sh

echo "Tomcat $VERSION started! Access at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"

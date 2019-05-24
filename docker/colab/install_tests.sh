#!/bin/bash

apt-get install -y openjdk-8-jdk mysql-client git netcat

pip3 install pydrill
pip3 install openpyxl
pip3 install pymysql
pip3 install gitpython

wget -O /tmp/apache_drill.tar.gz -nv http://archive.apache.org/dist/drill/drill-1.12.0/apache-drill-1.12.0.tar.gz
tar -xvzf /tmp/apache_drill.tar.gz -C /etc/
echo "export DRILL_JAVA_OPTS='-Duser.timezone=UTC'" >> /etc/apache-drill-1.12.0/conf/drill-env.sh
mkdir -p /etc/apache-drill-1.12.0/log/
chmod 777 /etc/apache-drill-1.12.0/log/

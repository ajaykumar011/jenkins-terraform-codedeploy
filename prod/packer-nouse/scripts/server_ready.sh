#!/bin/bash -xe
set -e

#DEBIAN_FRONTEND=noninteractive apt -yqq install <package> || echo 'Installation failed' ---- this install in silent mode
apt --version
DEBIAN_FRONTEND=noninteractive apt -yqq update || echo 'APT update failed'

DEBIAN_FRONTEND=noninteractive apt -yqq install software-properties-common 
add-apt-repository --yes ppa:ondrej/php
DEBIAN_FRONTEND=noninteractive apt -yqq update || echo 'APT update failed'

#Installation some basic things
DEBIAN_FRONTEND=noninteractive apt-get install -yqq curl net-tools wget expect

#Installation of LEMP
DEBIAN_FRONTEND=noninteractive apt -yqq install nginx mysql-server-5.7 mysql-client-core-5.7 php7.3-fpm php7.3-cli php7.3-common php7.3-curl php7.3-mbstring php7.3-mysql php7.3-xml php7.3-dev php7.3-xml php7.3-bcmath php7.3-zip || echo 'LEMP Insallation failed'

for r in nginx php7.3-fpm mysql; do systemctl start $r; done  
for r in nginx php7.3-fpm mysql; do systemctl enable $r; done  

MYSQL_PASS="mysupersecret"
mysql --version || { echo 'MySQL Service failed' ; exit 1; }

expect -f - <<-EOF
  set timeout 1
  spawn mysql_secure_installation
  expect "Press y|Y for Yes, any other key for No:"
  send -- "n\r"
  expect "New password:"
  send -- "${MYSQL_PASS}\r"
  expect "Re-enter new password:"
  send -- "${MYSQL_PASS}\r"
  expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
  send -- "y\r"
  expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
  send -- "y\r"
  expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
  send -- "y\r"
  expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
  send -- "y\r"
  expect eof
EOF

mysqladmin -u root -p$MYSQL_PASS ping

dbname=$(openssl rand -base64 12 | tr -dc A-Za-z | head -c 8 ; echo '')
dbuser=$(openssl rand -base64 12 | tr -dc A-Za-z | head -c 8 ; echo '')
dbpass=$(openssl rand -base64 8)

Q1="CREATE DATABASE IF NOT EXISTS $dbname;"
Q2="GRANT USAGE ON *.* TO $dbuser@localhost IDENTIFIED BY '$dbpass';"
Q3="GRANT ALL PRIVILEGES ON $dbname.* TO $dbuser@localhost;"
Q4="FLUSH PRIVILEGES;"
Q5="SHOW DATABASES;"  
SQL="${Q1}${Q2}${Q3}${Q4}${Q5}"
mysql -uroot -p$MYSQL_PASS -e "$SQL" || { echo 'MySQL Service failed' ; exit 1; }

chown -R $USER:www-data /var/www && chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \; 
find /var/www -type f -exec chmod 0664 {} \; 

#Log permission
chown -R $USER:www-data /var/log/nginx/
chown -R $USER:www-data /var/lib/php/sessions

######################AWS ESSENTIALS############################
REGION=us-east-1
AUTOUPDATE=false
# Installing Code Deploy Agent
DEBIAN_FRONTEND=noninteractive apt -yqq install jq awscli ruby wget || echo 'AWS-General Tools Installation failed'

cd /tmp/
wget -q https://aws-codedeploy-${REGION}.s3.amazonaws.com/latest/install || echo 'AWS code deploy Installer download faild'
chmod +x ./install
sudo ./install auto

service codedeploy-agent start
echo 'Code Deploy Agent Service Status: ' ; service codedeploy-agent status | grep 'Active'

# Install the Amazon CloudWatch Logs Agent
cd /home/ubuntu
DEBIAN_FRONTEND=noninteractive apt-get -yqq install build-essential libssl-dev libffi-dev libyaml-dev python-dev python-pip -y

wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb || echo 'Amazon cloudwatch agent download failed'
dpkg -i -E ./amazon-cloudwatch-agent.deb

curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O || echo 'Amazon AWS logs agent download failed'
chmod +x ./awslogs-agent-setup.py

#configuration part
wget -q https://s3.amazonaws.com/aws-codedeploy-us-east-1/cloudwatch/codedeploy_logs.conf || echo 'Amazon Code deploy log config failed'
mkdir -p /var/awslogs/etc/
cp codedeploy_logs.conf /var/awslogs/etc/

./awslogs-agent-setup.py -n -r us-east-1 -c /var/awslogs/etc/codedeploy_logs.conf
service awslogs start
echo 'AWSlogs Service Status: ' ;service awslogs status | grep 'Active'
# tail /var/log/awslogs.log
# Access Log on: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logs:
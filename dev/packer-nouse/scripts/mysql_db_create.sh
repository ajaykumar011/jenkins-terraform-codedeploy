#!/bin/bash

# set your variables here
apt -y install expect
MYSQL_PASS="mysupersecret"
apt-get -y install mysql-server
systemctl start mysql
systemctl enable mysql
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

Q1="CREATE DATABASE IF NOT EXISTS $dbname;"
Q2="GRANT USAGE ON *.* TO $dbuser@localhost IDENTIFIED BY '$dbpass';"
Q3="GRANT ALL PRIVILEGES ON $dbname.* TO $dbuser@localhost;"
Q4="FLUSH PRIVILEGES;"
Q5="SHOW DATABASES;"  
SQL="${Q1}${Q2}${Q3}${Q4}${Q5}"
mysql -uroot -p$MYSQL_PASS -e "$SQL" || { echo 'MySQL Service failed' ; exit 1; }




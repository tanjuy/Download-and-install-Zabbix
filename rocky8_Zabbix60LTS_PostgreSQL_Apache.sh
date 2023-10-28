#!/usr/bin/env bash
source ./terminal_color_font.sh


printf "
	Zabbix 6.0 LTS supported version: postgresql:13 - 16
	Please, check out https://www.zabbix.com/documentation/6.0/en/manual/installation/requirements
\n"

dnf module list postgresql

read -p "Choose supported version of zabbix: " version

dnf module enable postgresql:$version

dnf module list postgresql
sleep 10

dnf install postgresql-server -y

postgresql-setup --initdb

echo "\n${cyan}${bold}============================= Zabbix Installation  ===========================================${normal}"
echo "Install Zabbix repository\n\n"
sleep 2
rpm -Uvh https://repo.zabbix.com/zabbix/6.0/rhel/8/x86_64/zabbix-release-6.0-4.el8.noarch.rpm

dnf clean all

echo "${green}Install Zabbix server, frontend, agent${normal}\n\n"
sleep 2
dnf install zabbix-server-pgsql zabbix-web-pgsql zabbix-apache-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent -y

echo "Postgresql service is checked out and appended to startup file"
systemctl status postgresql
sleep 2

systemctl enable --now postgresql

systemctl status postgresql

echo "${yellow}${bold}Creating initial database${normal}"
sudo -u postgres createuser --pwprompt zabbix
sudo -u postgres createdb -O zabbix zabbix

echo "import initial schema and data"
zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix

read -s -p 'Configure the database for Zabbix server and Enter for database password: ' dbpassword

zabbix_server_conf=/etc/zabbix/zabbix_server.conf

if grep -q '# DBPassword=' $zabbix_server_conf; then
	sed -i "s/^# DBPassword=/DBPassword=$dbpassword/" $zabbix_server_conf
else
	echo 'Current Situation: '
	grep 'DBPassword=' $zabbix_server_conf
fi

systemctl restart postgresql
echo
echo "${yellow}${bold}Configuring Firewall : ${normal}"
firewall-cmd --list-all
echo
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=443/tcp --permanent
firewall-cmd --reload
echo
firewall-cmd --list-all
sleep 3

echo 'Zabbix Server, Zabbix Agent and php-fpm will be restarted'
sleep 2
systemctl restart zabbix-server zabbix-agent httpd php-fpm

echo 'Zabbix Server, Zabbix Agent and php-fpm will be appended to startup file'
systemctl enable zabbix-server zabbix-agent httpd php-fpm

pg_hba_conf_path=/var/lib/pgsql/data/pg_hba.conf

sed -i '83,90 s/peer/trust/g' $pg_hba_conf_path
sed -i '83,90 s/ident/trust/g' $pg_hba_conf_path

sed -i '87 i  host    all             all             0.0.0.0/0               trust' $pg_hba_conf_path

systemctl restart postgresql.service

IP_address=$(ip -c a | grep 'inet ' | grep -v '127' | awk '{print $2}' | awk -F '/' '{print $1}')
printf "
	Zabbix is installed successfully\n
	http://$IP_address/zabbix
"



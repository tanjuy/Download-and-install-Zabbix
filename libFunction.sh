#!/usr/bin/env bash
source ./terminal_color_font.sh


firewall_cmd() {

	echo "${yellow}${bold}Configuring Firewall : ${normal}"
	firewall-cmd --list-all
	echo "80, 443 and 10051 port are editing for zabbix "
	firewall-cmd --add-port=80/tcp --permanent
	firewall-cmd --add-port=443/tcp --permanent
	firewall-cmd --add-port=10051/tcp --permanent
	firewall-cmd --reload	
	firewall-cmd --list-all
	sleep 3
} # ------>  firewall_cmd

postgresql_conf() {
	
	local zabbix_server_conf=/etc/zabbix/zabbix_server.conf
	
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
	
	if grep -q '# DBPassword=' $zabbix_server_conf; then
	        sed -i "s/^# DBPassword=/DBPassword=$dbpassword/" $zabbix_server_conf
	else
	        echo 'Current Situation: '
	        grep 'DBPassword=' $zabbix_server_conf
	fi

	local pg_hba_conf_path=/var/lib/pgsql/data/pg_hba.conf

	sed -i '83,90 s/peer/trust/g' $pg_hba_conf_path
	sed -i '83,90 s/ident/trust/g' $pg_hba_conf_path

	sed -i '87 i  host    all             all             0.0.0.0/0               trust' $pg_hba_conf_path
	
	systemctl restart postgresql

}  # ------> Configure postgresql database to be available zabbix


services_restart () {
	
	echo 'Zabbix Server, Zabbix Agent, Apache and php-fpm will be restarted'
	sleep 2
	systemctl restart zabbix-server zabbix-agent httpd php-fpm

	echo 'Zabbix Server, Zabbix Agent, Apache and php-fpm will be appended to startup file'
	systemctl enable zabbix-server zabbix-agent httpd php-fpm

}  # ------> Zabbix Server, Zabbix Agent, Apache and php-fpm services

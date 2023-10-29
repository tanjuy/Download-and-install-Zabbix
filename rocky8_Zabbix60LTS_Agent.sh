#!/usr/bin/env bash

# Variables:
IP_address=$(ip -c a | grep 'inet ' | grep -v '127' | awk '{print $2}' | awk -F '/' '{print $1}')

echo 'Installing Zabbix repository'
sleep 1
rpm -Uvh https://repo.zabbix.com/zabbix/6.0/rhel/8/x86_64/zabbix-release-6.0-4.el8.noarch.rpm

dnf clean all

echo 'Installing Zabbix agent'
dnf install zabbix-agent

echo 'Starting Zabbix agent process'
systemctl restart zabbix-agent
sleep 1
systemctl enable zabbix-agent

echo 'Status Zabbix Agent:'
systemctl status zabbix-agent

echo 'Configuting Zabbix Agent: '

zabbix_agentd_conf=/etc/zabbix/zabbix_agentd.conf

read -p 'Enter a Zabbix Server IP: ' zabbix_server_ip

if grep -q 'Server=127.0.0.1' $zabbix_agentd_conf
	sed -i "s/^Server=127.0.0.1/Server=$zabbix_server_ip/" $zabbix_agentd_conf
	sed -i "s/^ServerActive=127.0.0.1/ServerActive=$zabbix_server_ip/" $zabbix_agentd_conf
	sed -i "s/^Hostname=Zabbix server/Hostname=$(hostname)/" $zabbix_agentd_conf
else
	echo "Please, configure manually $zabbix_agentd_conf file"
	echo "Edit Server=$IP_address and ServerActive=$IP_address and Hostname=$(hostname)"	
fi


echo "Firewall 10050/tcp port added"
firewall-cmd --add-port=10050 --permanent
firewall-cmd --reload

echo 'Restrating zabbix-agent'
sleep 2
systemctl restart zabbix-agent



printf "
	Zabbix Server Browser ---> Configuration Section ---> Hosts Subsection ---> Create host
	Popup:
		Host name: $(hostname)
		Visible name: 
		Templates: 
		Groups: 
		Add (click for adding interface)
			--> Select Agent or SNMP or JMX or IPMI
				--> Enter Zabbix Agent $IP_address	
"


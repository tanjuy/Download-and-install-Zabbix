#!/usr/bin/env bash

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

sed -i "s/Server=127.0.0.1/Server=$zabbix_server_ip/" $zabbix_agentd_conf

sed -i "s/ServerActive=127.0.0.1/ServerActive=$zabbix_server_ip/" $zabbix_agentd_conf

hostname_var=$(hostname)

sed -i "s/^Hostname=Zabbix Server/Hostname=$hostname_var/" $zabbix_agentd_conf

echo 'Restrating zabbix-agent'
sleep 2
systemctl restart zabbix-agent


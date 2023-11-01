#!/usr/bin/env bash

source ./terminal_color_font.sh
source ./libFunction.sh

printf "
	Zabbix 6.0 LTS supported version: postgresql:13 - 16
	Please, check out https://www.zabbix.com/documentation/6.0/en/manual/installation/requirements
\n"

dnf install postgresql-server -y

postgresql-setup --initdb

echo -e "\n${cyan}${bold}============================= Zabbix Installation  ===========================================${normal}"
echo -e "Install Zabbix repository\n\n"
sleep 2

sed -i '87 i excludepkgs=zabbix*' /etc/yum.repo.d/epel.repo

echo 'Install Zabbix repository'
rpm -Uvh https://repo.zabbix.com/zabbix/6.0/rhel/9/x86_64/zabbix-release-6.0-4.el9.noarch.rpm
dnf clean all

echo -e "${green}Install Zabbix server, frontend, agent${normal}\n\n"
sleep 2
dnf install zabbix-server-pgsql zabbix-web-pgsql zabbix-apache-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent

echo 
postgresql_conf
echo
firewall_cmd
echo
services_restart


IP_address=$(ip -c a | grep 'inet ' | grep -v '127' | awk '{print $2}' | awk -F '/' '{print $1}')
printf "
	Zabbix is installed successfully\n
	http://$IP_address/zabbix
	${red}${bold}Username: Admin -- Password: zabbix  Not: Please, change login Username and Password${normal}
"

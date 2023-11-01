#!/usr/bin/env bash

# Variables
distro=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
versionID=$(awk -F '/^NAME/{print $2}' /etc/os-release)


rocky8() {
	echo 
}



case "$distro,$versionID" in 
	'Rocky Linux,8.8')
		echo "Rocky Linux 8.8"
		bash ./rocky8_Zabbix60LTS_PostgreSQL_Apache.sh
		;;
	'Rocky Linux,9.0')
		echo "Rocky Linux 9.0"
		;;
	'Ubuntu,20.04')
		echo 'Ubuntu script will be appended'
		;;
esac

if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run by root" >&2
        exit 1
fi
FQDN=$1
SUB="$(cut -d'.' -f1 <<< "$1")"
ZONE="$(cut -d'.' -f2 <<< "$1")"
BESTANDSNAAM="db.$ZONE"

#check of het mrt wel bestaat

if [ -e "/etc/bind/mrt-tests/db.$BESTANDSNAAM"]; then
	#.conf bestand aanmaken in /etc/apache2/sites-available/mrt/...
	touch /etc/apache2/sites-available/mrt/$ZONE.conf
	FILE="/etc/apache2/sites-available/mrt/"$ZONE".conf"
	echo "<VirtualHost *:80>" >> $FILE
	echo "ServerName"$SUB"."$ZONE".sb.uclllabs.be" >> $FILE
	echo "ServerAdmin webmaster@localhost" >> $FILE
	echo "DocumentRoot /var/www/"$SUB"/html" >> $FILE
	echo "ErrorLog ${APACHE_LOG_DIR}/error.log" >> $FILE
	echo "CustomLog ${APACHE_LOG_DIR}/access.log combined" >> $FILE
	echo "</VirtualHost>" >> $FILE

	#index.html aanmaken
	mkdir /var/www/$SUB/html
	touch /var/www/$SUB/html/index.html
	FILE2="/var/www/"$SUB"/html/index.html"
	echo "welcome $SUB.$ZONE" >> $FILE2
else
	exit 1
fi

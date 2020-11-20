if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run by root" >&2
        exit 1
fi
FQDN=$1
ZONE="$(cut -d'.' -f1 <<< "$1")"
SUB="$(cut -d'.' -f2 <<< "$1")"
BESTANDSNAAM="db.$SUB"

#check of het mrt wel bestaat

if [ -e "/etc/bind/mrt-tests/$BESTANDSNAAM" ]; then
	#.conf bestand aanmaken in /etc/apache2/sites-available
	if [ -e "/etc/apache2/sites-available/script_$ZONE.conf" ]; then
		echo "het bestand .conf bestaat al"
	else
		echo "Maken van het .conf bestand"
		touch "/etc/apache2/sites-available/script_$ZONE.conf"
		FILE="/etc/apache2/sites-available/script_$ZONE.conf"
		echo "<VirtualHost *:80>" >> $FILE
		echo "ServerName $ZONE.$SUB.dieter-claessens.sb.uclllabs.be" >> $FILE
		echo "ServerAdmin root@dieter-claessens.sb.uclllabs.be" >> $FILE
		echo "DocumentRoot /var/www/$ZONE/$SUB/html" >> $FILE
		echo "ErrorLog \${APACHE_LOG_DIR}/$ZONE-$SUB-error.log" >> $FILE
		echo "CustomLog \${APACHE_LOG_DIR}/$ZONE-$SUB-access.log combined" >> $FILE
		echo "</VirtualHost>" >> $FILE
	fi
	#index.html aanmaken
	if [ -e "/var/www/$ZONE" ]; then
		echo "index.html bestaat al"
	else
		mkdir "/var/www/$ZONE"
		mkdir "/var/www/$ZONE/$SUB"
		mkdir "/var/www/$ZONE/$SUB/html"
		touch "/var/www/$ZONE/$SUB/html/index.html"
		FILE2="/var/www/$ZONE/$SUB/html/index.html"
		echo "welcome $ZONE.$SUB" >> $FILE2
	fi
	a2ensite script_$ZONE.conf
	systemctl reload apache2
else
	echo "Het juiste bestand werd niet gevonden in /etc/bind/mrt-tests/..."
	exit 1
fi

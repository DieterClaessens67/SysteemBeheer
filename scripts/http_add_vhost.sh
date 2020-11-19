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
	#.conf bestand aanmaken in /etc/apache2/sites-available/mrt/...
	echo "Maken van de bestanden"
	touch "/etc/apache2/sites-available/mrt/$ZONE.conf"
	FILE="/etc/apache2/sites-available/mrt/"$ZONE".conf"
	echo "<VirtualHost *:80>" >> $FILE
	echo "ServerName"$SUB"."$ZONE".sb.uclllabs.be" >> $FILE
	echo "ServerAdmin webmaster@localhost" >> $FILE
	echo "DocumentRoot /var/www/$ZONE/$SUB/html" >> $FILE
	echo "ErrorLog ${APACHE_LOG_DIR}/error.log" >> $FILE
	echo "CustomLog ${APACHE_LOG_DIR}/access.log combined" >> $FILE
	echo "</VirtualHost>" >> $FILE

	#index.html aanmaken
	mkdir "/var/www/$ZONE"
	mkdir "/var/www/$ZONE/$SUB"
	mkdir "/var/www/$ZONE/$SUB/html"
	touch "/var/www/$ZONE/$SUB/html/index.html"
	FILE2="/var/www/$ZONE/$SUB/html/index.html"
	echo "welcome $ZONE.$SUB" >> $FILE2

	a2ensite "mrt/$ZONE.conf"
	systemctl reload apache2
else
	echo "Het juiste bestand werd niet gevonden in /etc/bind/mrt-tests/..."
	exit 1
fi

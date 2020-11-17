if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run by root" >&2
        exit 1
fi

FILE = "/etc/apache2/sites-available/mrt/"$VHOST".conf"
echo "<VirtualHost *:80>" >> $FILE
echo "ServerName" $VHOST"."$SUBDOMAIN".sb.uclllabs.be" >> $FILE
echo "ServerAdmin webmaster@localhost" >> $FILE
echo "DocumentRoot /var/www/"$VHOST"/html" >> $FILE
echo "ErrorLog ${APACHE_LOG_DIR}/error.log" >> $FILE
echo "CustomLog ${APACHE_LOG_DIR}/access.log combined" >> $FILE
echo "</VirtualHost>" >> $FILE

FILE2 "/var/www/"$VHOST"/html/index.html"
echo "welcome "$VHOST"" >> $FILE2

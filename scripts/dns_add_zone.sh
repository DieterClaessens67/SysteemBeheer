#! /bin/bash
if [ $# -eq 0 ]
  then
    echo "No arguments supplied" >&2
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run by root" >&2
        exit 1
fi


ZONE=$1

touch /etc/bind/mrt-tests/zone.$ZONE

echo 'zone "'$ZONE'.dieter-claessens.sb.uclllabs.be" {' >> /etc/bind/mrt-tests/zone.$ZONE
echo '    type master;' >> /etc/bind/mrt-tests/zone.$ZONE
echo '    file "/etc/bind/mrt-tests/db.'$ZONE'";' >> /etc/bind/mrt-tests/zone.$ZONE
echo '	  allow-transfer { 193.191.177.148; };' >> /etc/bind/mrt-tests/zone.$ZONE
echo '};' >> /etc/bind/mrt-tests/zone.$ZONE


echo ";" >> /etc/bind/mrt-tests/db.$ZONE
echo "; BIND data file for local loopback interface" >> /etc/bind/mrt-tests/db.$ZONE
echo ";" >> /etc/bind/mrt-tests/db.$ZONE
echo "\$TTL    604800" >> /etc/bind/mrt-tests/db.$ZONE
echo "\$ORIGIN "$ZONE".dieter-claessens.sb.uclllabs.be." >> /etc/bind/mrt-tests/db.$ZONE
echo "@       IN      SOA     ns.$ZONE.dieter-claessens.sb.uclllabs.be. root.$ZONE.dieter-claessens.sb.uclllabs.be. (" >> /etc/bind/mrt-tests/db.$ZONE
echo "                              2         ; Serial" >> /etc/bind/mrt-tests/db.$ZONE
echo "                         604800         ; Refresh" >> /etc/bind/mrt-tests/db.$ZONE
echo "                          86400         ; Retry" >> /etc/bind/mrt-tests/db.$ZONE
echo "                        2419200         ; Expire" >> /etc/bind/mrt-tests/db.$ZONE
echo "                         604800 )       ; Negative Cache TTL" >> /etc/bind/mrt-tests/db.$ZONE
echo ";" >> /etc/bind/mrt-tests/db.$ZONE
#echo "@       IN      NS      ns."$ZONE".dieter-claessens.sb.uclllabs.be." >> /etc/bind/mrt-tests/db.$ZONE
echo "@       IN      NS      ns.dieter-claessens.sb.uclllabs.be." >> /etc/bind/mrt-tests/db.$ZONE
echo "@	      IN      A       193.191.177.148" >> /etc/bind/mrt-tests/db.$ZONE
echo "ns      IN      A       193.191.177.148" >> /etc/bind/mrt-tests/db.$ZONE

echo 'include "/etc/bind/mrt-tests/zone.'$ZONE'";' >> /etc/bind/named.conf.mrt-zones

echo $ZONE'	IN	NS	ns.dieter-claessens.sb.uclllabs.be.' >> /etc/bind/db.local

# increment serial
SERIAL=$(grep -Po '\d+(?=\s+; Serial)' /etc/bind/db.local)
NEW_SERIAL=$(("$SERIAL" + 1))
sed -i "0,/$SERIAL/s//$NEW_SERIAL/" /etc/bind/db.local


systemctl restart bind9.service


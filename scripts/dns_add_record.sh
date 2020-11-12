#! /bin/bash

# functions

function extract_subdomain(){
    DELIMETER=$1
    STRING=$2
    IFS=$DELIMETER
    read -ra NAMES <<< $STRING
    SUBDOMAIN=${NAMES[0]}
    echo $SUBDOMAIN
}

function add_a_record(){
    SUBDOMAIN=$(extract_subdomain '.' $3)
    if [ -e "/etc/bind/mrt-tests/db.$SUBDOMAIN" ] 
    then
        echo "$1  IN  A    $2"  >> "/etc/bind/mrt-tests/db.$SUBDOMAIN"
    else
        echo "db file for $SUBDOMAIN does not exists"
        exit 1
    fi 
}

RECORD_TYPE="A"

while getopts ":t:" opt; do
  case $opt in
    t) RECORD_TYPE="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [ $1 != "-t" ]; then
    add_a_record $1 $2 $3
    exit 0
fi
case $RECORD_TYPE in
    "A")
        NAME=$3
        IP=$4
        FQDN=$5
        add_a_record "$NAME" "$IP" "$FQDN"
    ;;
    "CNAME")
        ALIAS=$3
        FQDN=$4
        SUBDOMAIN=$(extract_subdomain '.' $FQDN)
        if [ -e "/etc/bind/mrt-tests/db.$SUBDOMAIN" ] 
        then
            echo "$ALIAS  IN  $RECORD_TYPE    $FQDN."  >> "/etc/bind/mrt-tests/db.$SUBDOMAIN"
        else
            echo "db file for $SUBDOMAIN does not exists"
            exit 1
        fi
    ;;
    "MX")
        MXNAME=$3
        IP=$4
        FQDN=$5
        SUBDOMAIN=$(extract_subdomain '.' $FQDN)
        if [ -e "/etc/bind/mrt-tests/db.$SUBDOMAIN" ] 
        then
            echo "       IN       $RECORD_TYPE    10    $MXNAME"  >> "/etc/bind/mrt-tests/db.$SUBDOMAIN"
            echo "$MXNAME      IN       A        $IP"  >> "/etc/bind/mrt-tests/db.$SUBDOMAIN"
        else
            echo "db file for $SUBDOMAIN does not exists"
            exit 1
        fi
    ;;
esac
systemctl restart bind9.service


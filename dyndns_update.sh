#!/bin/bash
#
# precondition:
# installed packages: dig, curl
# dyndns entry has do be set to a valid IP such as 127.0.0.1 / vaid IPv6
#

# enable IPv4 and / or IPv6 updateing
# Values: 0 - diabled; 1 - enabled
ENA_IPv4=1
ENA_IPv6=1

# variables
DATE=$(date +"%D-%H:%M")
LOGBASE="/var/log"
LOGFILE="dyndns_update.txt"
DNSSRV="@9.9.9.9"

# Debugging enable 1 disable 0
# while debug enabled, no update takes place
DEBUG=0

# regex to identify if incoming string is an IPv4 or IPv6
IPv4_REX='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
IPv6_REX='^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$'

# Dyndns informationen
FQDN="<FQDN>" # hostname + domain
SECRET="<SECRET>" # key to allow the update

# obtain IPv4 and IPv6 information from dyndns.org - based NOT on REGEX
IPv4=$(curl -s -0 -4 checkip.dyndns.org | awk  '{ print $6 }' | cut -f 1 -d "<")
IPv6=$(curl -s -0 -6 checkipv6.dyndns.org |  awk  '{ print $6 }' | cut -f 1 -d "<")
#IPv6=$(curl -s -0 -6 checkipv6.dyndns.org |  awk  '{ print $6 }' | rev | cut -c16- | rev)

# IPv4 update
if [ $ENA_IPv4 == "1" ]; then
    if [[ $IPv4 !=  "" ]]
     then
        if [ $DEBUG == "1" ]; then echo "Local IPv4: $IPv4"; fi

        # get external IPv4 from DNS
        GETDNSIPv4=$(dig +short A $FQDN $DNSSRV | tr -d '\n')
        if [ $DEBUG == "1" ]; then echo "Exernal DNS FQDN - IPv4: $FQDN - $GETDNSIPv4"; fi

        # check if DNS entry coming back is an IP Adress
        #if [[ $GETDNSIPv4 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        if [[ $GETDNSIPv4 =~ $IPv4_REX ]]; then
            if [ $DEBUG == "1" ]; then echo "ok - DNS answer is an IPv4:" $GETDNSIPv4; fi

            # check if external entry is similar to local IP
            if [ "$IPv4" != "$GETDNSIPv4" ]; then
                if [ $DEBUG == "1" ]; then echo "IP Comparism INT - EXT: $IPv4 - $GETDNSIPv4"; fi
                if [ $DEBUG == "1" ]; then echo  "Updatestring: https://dynamicdns.key-systems.net/update.php?hostname=$FQDN&password=$SECRET&ip=$IPv4" && sleep 5; fi
                if [ $DEBUG == "0" ]; then curl -0 -s "https://dynamicdns.key-systems.net/update.php?hostname=$FQDN&password=$SECRET&ip=$IPv4"  > /dev/null; fi
                if [ $DEBUG == "0" ]; then logger "DynDNS - Entry updated for IPv4: $FQDN to $IPv4"; fi
           #else
           #     echo "no update"
           fi

        else
            if [ $DEBUG == "1" ]; then echo "fail - DNS answer is an IPv4:" $GETDNSIPv4; fi
            logger "dyndns - DNS request check failed: $FQDN - GETDNSIPv4"
        fi

    fi
fi

#IPv6 update
if [ $ENA_IPv6 == "1" ]; then
    if [[ $IPv6 !=  "" ]]
     then
        if [ $DEBUG == "1" ]; then echo "Local IPv6: $IPv6"; fi

        # get external IPv6 from DNS
        GETDNSIPv6=$(dig +short AAAA $FQDN $DNSSRV | tr -d '\n')
        if [ $DEBUG == "1" ]; then echo "Exernal DNS FQDN - IPv6: $FQDN - $GETDNSIPv6"; fi

        # check if DNS entry coming back is an IP Adress
        if [[ $GETDNSIPv6 =~ $IPv6_REX ]]; then
            if [ $DEBUG == "1" ]; then echo "ok - DNS answer is an IPv6:" $GETDNSIPv6; fi

            # check if external entry is similar to local IP
            if [ "$IPv6" != "$GETDNSIPv6" ]; then
                if [ $DEBUG == "1" ]; then echo "IP Comparism INT - EXT: $IPv6 - $GETDNSIPv6"; fi
                if [ $DEBUG == "1" ]; then echo  "Updatestring: https://dynamicdns.key-systems.net/update.php?hostname=$FQDN&password=$SECRET&ip=$IPv6" && sleep 5; fi
                if [ $DEBUG == "0" ]; then curl -0 -s "https://dynamicdns.key-systems.net/update.php?hostname=$FQDN&password=$SECRET&ip=$IPv6"  > /dev/null; fi
                if [ $DEBUG == "0" ]; then logger "DynDNS - Entry updated for IPv6: $FQDN to $IPv6"; fi
            #else
            #    echo "no update"
            fi

        else
            if [ $DEBUG == "1" ]; then echo "fail - DNS answer is an IPv6:" $GETDNSIPv6; fi
            logger "DynDNS - DNS request check failed: $FQDN - GETDNSIPv6"
        fi
    fi
fi

# if you run that the firt time
# initialise the dyndns names
if [ $DEBUG == "1" ]; then
	read -p "Do you want to iniciate the dynamic DNS names ? Yes/No :" yn2
	case $yn2 in
	  [Yy]*)
            if [ $ENA_IPv4 == "1" ]; then curl -s -0  "https://dynamicdns.key-systems.net/update.php?hostname=$FQDN&password=$SECRET&ip=$IPv4"; fi
            if [ $ENA_IPv6 == "1" ]; then curl -s -0  "https://dynamicdns.key-systems.net/update.php?hostname=$FQDN&password=$SECRET&ip=$IPv6"; fi
	   ;;
	  *)
	    echo "not updated"
	esac
fi

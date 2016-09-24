#!/usr/bin/env bash

# (optional) You might need to set your PATH variable at the top here
# depending on how you run this script
#PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin



# Functions
function valid_ip()
{
    local ip=$1
    local stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

function clean_up()
{
    rm $TMPFILE ${LOGFILE}.tmp 2>/dev/null
}

function handle_err()
{
    echo Something broke
    clean_up
    exit 1
}
# End functions



# MAIN
if [ "$#" -ne 1 ]; then
    echo Usage: $0 host.domain.com
    exit 1
fi

trap handle_err ERR

DIR=~
LOGFILE="$DIR/update-route53.log"
IPFILE="$DIR/update-route53.ip"

# Hosted Zone ID e.g. BJBK35SKMM9OE
ZONEID="YOUR_HOSTED_ZONE_ID_HERE"

# The CNAME you want to update e.g. hello.example.com
RECORDSET=$1

# More advanced options below
# The Time-To-Live of this recordset
TTL=300
# Change this if you want
COMMENT="Auto updating @ `date`"
# Change to AAAA if using an IPv6 address
TYPE="A"

# Choose from several options to get your IP:
#IPPROVIDER=http://ifconfig.me/ip
#IPPROVIDER=https://icanhasip.com/
IPPROVIDER=https://wtfismyip.com/text

# Get the external IP address
IP=`curl -sS $IPPROVIDER`

if ! valid_ip $IP; then
    echo "Invalid IP address: $IP" >> ${LOGFILE}
    exit 1
fi

# Check if the IP has changed
[ ! -f "$IPFILE" ] && touch "$IPFILE"
if grep -Fxq "$IP" "$IPFILE"; then
    # code if found
    # echo "IP is still $IP, exiting" >> ${LOGFILE}
    exit 0
else
    echo "IP has changed to $IP" >> ${LOGFILE}.tmp
    # Fill a temp file with valid JSON
    TMPFILE=$(mktemp /tmp/temporary-file.XXXXXXXX)
    cat > ${TMPFILE} << EOF
{
  "Comment":"$COMMENT",
  "Changes":[
    {
      "Action":"UPSERT",
      "ResourceRecordSet":{
        "Name":"${RECORDSET}.",
        "Type":"$TYPE",
        "TTL":$TTL,
        "ResourceRecords":[{"Value":"$IP"}]
      }
    }
  ]
}
EOF
    cat ${TMPFILE}

    # Update the Hosted Zone record
    aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONEID \
        --change-batch file://"$TMPFILE" >> ${LOGFILE}.tmp
    # If no errors, save logfile
    cat ${LOGFILE}.tmp >> ${LOGFILE}

    clean_up
fi

# All Done - cache the IP address for next time
echo "$IP" > "$IPFILE"

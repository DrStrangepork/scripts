#!/usr/bin/env bash
profile=${AWS_DEFAULT_PROFILE:-none}
IPPROVIDER=https://wtfismyip.com/text
COMMENT="Auto updating @ $(date)"
IPFILE="$HOME/update-route53.ip"
LOGFILE="$HOME/update-route53.log"
TTL=300
VERBOSE=false



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
    rm ${TMPFILE} ${LOGFILE}.tmp 2>/dev/null
}

function handle_err()
{
    echo Something broke
    clean_up
    exit 1
}
# End functions


usage() {
  echo \
"$(tput bold)$(basename ${BASH_SOURCE[0]})$(tput sgr0)
Usage:  Automatically updates a record set in AWS Route 53 whenever ISP
        provider DHCP address changes
Example:  $(basename ${BASH_SOURCE[0]}) -r host.example.com -z Z15KQT7M7VECQE
Required: -r RECORDSET -z ZONEID
Options:
  -r RECORDSET  FQDN of the host to check
  -z ZONEID     Hosted zone ID
  -c COMMENT    Change comment (default: \"Auto updating @ $(date)\")
  -i IPPROVIDER URL of IP dection service (default: https://wtfismyip.com/text)
                    Ex. http://ifconfig.me/ip, https://icanhasip.com/
  -l LOGFILE    Output log (default: LOGFILE=\"~/update-route53.log\")
  -s IPFILE     IP state file (default: \"~/update-route53.ip\")
  -t TTL        Time to live (TTL) (default: 300s)
  -v            verbose
  -p PROFILE    AWS profile (default: AWS_DEFAULT_PROFILE or \"none\")
  -h            help"
}


prereq="Prerequisites are missing and must be installed before continuing:\n"
missing_req=false
if ! aws --version >/dev/null 2>&1; then
  prereq+="\t'aws' python cli from http://aws.amazon.com/cli/\n"
  missing_req=true
fi
if $missing_req; then
  echo -e "Error: $prereq" >&2
  exit 1
fi


[[ "$*" =~ "--help" ]] && { usage | less; exit; }
while getopts ":c:i:l:p:r:s:t:vz:h" opt; do
  case $opt in
    c)  COMMENT=$OPTARG
        ;;
    i)  IPPROVIDER=$OPTARG
        ;;
    l)  LOGFILE=$OPTARG
        ;;
    p)  profile=$OPTARG
        ;;
    r)  RECORDSET=$OPTARG
        ;;
    s)  IPFILE=$OPTARG
        ;;
    t)  TTL=$OPTARG
        ;;
    v)  VERBOSE=true
        ;;
    z)  ZONEID=$OPTARG
        ;;
    h)  usage ; exit
        ;;
    *)  echo "Error: invalid option -$OPTARG" >&2
        usage ; exit 1
        ;;
  esac
done
[[ -n "$RECORDSET" || -n "$ZONEID" ]] || { usage; exit 1; }



# MAIN
trap handle_err ERR

# Get the external IP address
IP=$(curl -sS $IPPROVIDER)

if ! valid_ip $IP; then
    echo "Invalid IP address: $IP" >> ${LOGFILE}
    exit 1
fi

# Check if the IP has changed
[ ! -f "$IPFILE" ] && touch "$IPFILE"
if grep -Fxq "$IP" "$IPFILE"; then
    $VERBOSE && echo "IP is still $IP, exiting" | tee -a ${LOGFILE}
    exit 0
else
    $VERBOSE && echo "IP has changed to $IP" >> ${LOGFILE}.tmp
    TMPFILE=$(mktemp /tmp/temporary-file.XXXXXXXX)
    cat > ${TMPFILE} << EOF
{
  "Comment": "$COMMENT",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${RECORDSET}.",
        "Type": "A",
        "TTL": $TTL,
        "ResourceRecords": [{"Value":"$IP"}]
      }
    }
  ]
}
EOF
    $VERBOSE && cat ${TMPFILE}

    # Update the Hosted Zone record
    aws --profile $profile route53 change-resource-record-sets \
        --hosted-zone-id $ZONEID \
        --change-batch file://"${TMPFILE}" >> ${LOGFILE}.tmp
    # If no errors, save logfile
    cat ${LOGFILE}.tmp >> ${LOGFILE}

    clean_up
fi

# All Done - cache the IP address for next time
echo "$IP" > "$IPFILE"

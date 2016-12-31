#!/usr/bin/env bash
AWSRegs="ap-northeast-1 ap-southeast-1 ap-southeast-2 eu-central-1 eu-west-1 sa-east-1 us-east-1 us-west-1 us-east-1"
profile=${AWS_DEFAULT_PROFILE:-none}
regions=${AWS_DEFAULT_REGION:-us-east-1}
FORCE=false


usage() {
  echo \
"$(tput bold)$(basename ${BASH_SOURCE[0]})$(tput sgr0)
Usage:  Deletes EC2 instance based on lookup of InstanceId or PublicDnsName,
        and deletes its rootDeviceName volume
Example:  $(basename ${BASH_SOURCE[0]}) -i i-12345678 -r us-east-1
Required: -i or -d (one required but not both)
Options:
  -d PublicDnsName[,PublicDnsName,..]   PublicDnsName(s)
  -i InstanceId[,InstanceId,..]         InstanceId(s)
  -f            force (disable termination protection)
  -p            AWS profile (default: AWS_DEFAULT_PROFILE or \"none\")
  -r            region (default: AWS_DEFAULT_REGION or us-east-1)
  -h            help"
}


prereq="Prerequisites are missing and must be installed before continuing:\n"
missing_req=false
if ! which aws >/dev/null 2>&1; then
  prereq+="\t'aws' python cli from http://aws.amazon.com/cli/\n"
  missing_req=true
fi
if $missing_req; then
  echo -e "Error: $prereq" >&2
  exit 1
fi


[[ "$@" =~ "--help" ]] && { usage | less; exit; }
while getopts ":d:fi:p:r:h" opt; do
  case $opt in
    d)  [ -n "$IIDs" ] && { usage; exit 1; }
        echo -n "Looking up InstanceId's..."
        while IFS=',' read -ra DNS; do
          for i in "${DNS[@]}"; do
            #if [[ ! "$i" =~ ec2-[0-9]+-[0-9]+-[0-9]+-[0-9]+\.compute-1\.amazonaws\.com$ && \
            #    ! "$i" =~ ec2-[0-9]+-[0-9]+-[0-9]+-[0-9]+\.[a-z][a-z]-[a-z]*-[1-2]\.compute\.amazonaws\.com$ ]]; then
            if [[ ! "$i" =~ ^ec2-[0-9]+-[0-9]+-[0-9]+-[0-9]+\.us-east-1\.compute\.amazonaws\.com$ ]]; then
              echo "Invalid AWS Public DNS name: $i"
              exit 1
            fi
            IID=$(aws ec2 describe-instances --filters Name=dns-name,Values=$i --query 'Reservations[].Instances[].[InstanceId]' --output text)
            if [[ "$?" -ne "0" || -z "$IID" ]]; then
              echo "No EC2 instance found with Public DNS name $i"
              exit 1
            fi
            IIDs+="$IID "
          done
        done <<< "${OPTARG,,}"    # ${OPTARG,,} converts $OPTARG to all lowercase letters
        echo "Done"
        ;;
    f)  FORCE=true
        ;;
    i)  [ -n "$DNS" ] && { usage; exit 1; }
        while IFS=',' read -ra IID; do
          for i in "${IID[@]}"; do
            if [[ ! "$i" =~ ^i-[a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9]$ ]]; then
              echo "Invalid AWS Instance ID: $i"
              exit 1
            fi
            IIDs+="$i "
          done
        done <<< "${OPTARG,,}"    # ${OPTARG,,} converts $OPTARG to all lowercase letters
        ;;
    p)  profile=$OPTARG
        ;;
    r)  [ "${OPTARG,,}" == "all" ] && { regions=$AWSRegs; continue; }
        unset regions
        while IFS=',' read -ra REGION; do
          for i in "${REGION[@]}"; do
            FOUND=false
            for reg in $AWSRegs; do
              [ "$reg" == "$i" ] && FOUND=true
            done
            if $FOUND; then
                regions+="$i "
            else
              echo "Error: invalid region - $i" >&2
              echo "Valid regions are: $AWSRegs" | fold -s >&2
              exit 1
            fi
          done
        done <<< "${OPTARG,,}"    # ${OPTARG,,} converts $OPTARG to all lowercase letters
        ;;
    h)  usage ; exit
        ;;
    *)  echo "Error: invalid option -$OPTARG" >&2
        usage ; exit 1
        ;;
  esac
done
[ -n "$IIDs" ] || { usage; exit 1; }


## MAIN
for reg in $regions; do
  # Get InstanceIds
  for IID in $IIDs; do
    # Disable termination protection
    if $FORCE; then
      aws --profile $profile --region $reg ec2 modify-instance-attribute --instance-id $IID --no-disable-api-termination
      if [ "$?" -ne "0" ]; then
        echo " ** Failed to disable termination protection - $IID" >&2
        exit 1
      fi
    fi

    # Set "RootDeviceName" to "DeleteOnTermination"=="true"
    rootDN=$(aws --profile $profile --region $reg ec2 describe-instance-attribute --instance-id $IID --attribute rootDeviceName --query "RootDeviceName.Value" --output text)
    aws --profile $profile --region $reg ec2 modify-instance-attribute --instance-id $IID --block-device-mappings "[{\"DeviceName\":\"${rootDN}\",\"Ebs\":{\"DeleteOnTermination\":true}}]"
    if [ "$?" -ne "0" ]; then
      echo " ** Failed to set \"DeviceName\": \"${rootDN}\" to \"DeleteOnTermination\":true  - $IID" >&2
      exit 1
    fi
    RES=$(aws --profile $profile --region $reg ec2 terminate-instances --instance-id $IID --query 'TerminatingInstances[].CurrentState.Name' --output text 2>/dev/null)
    if [[ "$?" -ne "0" || -z $RES ]]; then
      echo "Termination failed - $IID" >&2
      exit 1
    else
      echo $IID $RES
    fi
  done
done

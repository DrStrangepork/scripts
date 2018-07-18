#!/usr/bin/env bash
AWSRegs="ap-northeast-1 ap-northeast-2 ap-south-1 ap-southeast-1 ap-southeast-2 ca-central-1 eu-central-1 eu-west-1 eu-west-2 eu-west-3 sa-east-1 us-east-1 us-east-2 us-west-1 us-west-2"
profile=${AWS_DEFAULT_PROFILE:-none}
regions=${AWS_DEFAULT_REGION:-us-east-1}


usage() {
  echo \
"$(tput bold)$(basename ${BASH_SOURCE[0]})$(tput sgr0)
Usage:  Queries CloudWatch for alarms of InstanceId dimensions, then queries
        EC2 for the status of each InstanceId, and if it not in a running
        state, all its CloudWatch alarms are deleted
Example:  $(basename ${BASH_SOURCE[0]})
Options:
  -p            AWS profile (default: AWS_DEFAULT_PROFILE or \"none\")
  -r            comma-delimited list of regions
                  (default: AWS_DEFAULT_REGION or us-east-1; \"all\" = all)
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
while getopts ":p:r:h" opt; do
  case $opt in
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
[[ -n "$STACKNAME" || -n "$TEMPLATE" ]] || { usage; exit 1; }


## MAIN
for IID in $(aws --profile $profile --region $reg cloudwatch describe-alarms --query 'MetricAlarms[].Dimensions[?Name==`InstanceId`].Value' --output text | uniq); do
  if ! aws --profile $profile --region $reg ec2 describe-instances --instance-ids $IID --filters Name=instance-state-name,Values=running >/dev/null 2>&1; then
    for AlarmName in $(aws --profile $profile --region $reg cloudwatch describe-alarms --query 'MetricAlarms[?Dimensions[?Value==`'$IID'`]].AlarmName' --output text); do
        aws --profile $profile --region $reg cloudwatch delete-alarms --alarm-names $AlarmName && echo Alarm $AlarmName deleted
    done
  fi
done

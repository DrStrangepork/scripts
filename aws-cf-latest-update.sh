#!/usr/bin/env bash
AWSRegs="ap-northeast-1 ap-northeast-2 ap-south-1 ap-southeast-1 ap-southeast-2 ca-central-1 eu-central-1 eu-west-1 eu-west-2 eu-west-3 sa-east-1 us-east-1 us-east-2 us-west-1 us-west-2"
profile=${AWS_DEFAULT_PROFILE:-none}
region=${AWS_DEFAULT_REGION:-us-east-1}


usage() {
  echo \
"$(tput bold)$(basename ${BASH_SOURCE[0]})$(tput sgr0)
Usage:  Returns the date of the most recent update to the CloudFormation
        template of STACKNAME (date is in UTC)
Example:  $(basename ${BASH_SOURCE[0]}) -s svc-stack -r us-west-2
Required: -s STACKNAME
Options:
  -s STACKNAME  name of stack
  -p            AWS profile (default: AWS_DEFAULT_PROFILE or \"none\")
  -r            region (default: AWS_DEFAULT_REGION or us-east-1)
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
while getopts ":p:r:s:h" opt; do
  case $opt in
    p)  profile=$OPTARG
        ;;
    r)  region=${OPTARG,,}  # ${OPTARG,,} converts $OPTARG to all lowercase letters
        FOUND=false
        for reg in $AWSRegs; do
          [ "$reg" == "$region" ] && FOUND=true
        done
        if [ ! $FOUND ]; then
          echo "Error: invalid region - $reg" >&2
          echo "Valid regions are: $AWSRegs" | fold -s >&2
          exit 1
        fi
        ;;
    s)  STACKNAME=$OPTARG
        ;;
    h)  usage ; exit
        ;;
    *)  echo "Error: invalid option -$OPTARG" >&2
        usage ; exit 1
        ;;
  esac
done
[[ -n "$STACKNAME" ]] || { usage; exit 1; }


## MAIN
if ! event="$(IFS="\n" && \
    aws --profile $profile --region $region cloudformation describe-stack-events --stack-name $STACKNAME \
    --query='StackEvents[?ResourceType==`AWS::CloudFormation::Stack` && (ResourceStatus==`CREATE_COMPLETE` || ResourceStatus==`UPDATE_COMPLETE`)] | [].[ResourceStatus,Timestamp]' \
    --max-items 1 --output text 2>/dev/null)"; then
  echo "Error: Failed to retreive stack $OPTARG with profile $profile in region $region" >&2
  exit 1
fi
status=$(echo $event | cut -d ' ' -f 1)
timestamp=$(echo $event | cut -d ' ' -f 2)
echo Most recent update to stack $STACKNAME was $status at $timestamp

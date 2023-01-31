#!/usr/bin/env bash
AWSRegs="ap-northeast-1 ap-northeast-2 ap-south-1 ap-southeast-1 ap-southeast-2 ca-central-1 eu-central-1 eu-west-1 eu-west-2 eu-west-3 sa-east-1 us-east-1 us-east-2 us-west-1 us-west-2"
profile=${AWS_DEFAULT_PROFILE:-none}
regions=${AWS_DEFAULT_REGION:-us-east-1}


usage() {
  echo \
"$(tput bold)$(basename ${BASH_SOURCE[0]})$(tput sgr0)
Usage:  Deletes CloudFormation stack STACKNAME from region(s) REGION[,REGION,...]
Example:  $(basename ${BASH_SOURCE[0]}) -s svc-stack -r us-east-1,us-west2
Required: -s STACKNAME
Options:
  -s STACKNAME  name of stack
  -p            AWS profile (default: AWS_DEFAULT_PROFILE or \"none\")
  -r            comma-delimited list of regions
                  (default: AWS_DEFAULT_REGION or us-east-1; \"all\" = all)
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
    r)  [ "${OPTARG,,}" == "all" ] && { regions=$AWSRegs; continue; }
        unset regions
        while IFS=',' read -ra REGION; do
          for i in "${REGION[@]}"; do
            FOUND=false
            for reg in $AWSRegs; do
              [ "$reg" == "$i" ] && FOUND=true
            done
            if [ $FOUND ]; then
                regions+="$i "
            else
              echo "Error: invalid region - $i" >&2
              echo "Valid regions are: $AWSRegs" | fold -s >&2
              exit 1
            fi
          done
        done <<< "${OPTARG,,}"    # ${OPTARG,,} converts $OPTARG to all lowercase letters
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
for reg in $regions; do
  if ! aws --profile $profile --region $reg cloudformation describe-stacks --stack-name $STACKNAME >/dev/null 2>&1; then
    echo "Error: Failed to retrieve stack $STACKNAME in region $reg" >&2
    exit 1
  fi
  echo aws --profile $profile --region $reg cloudformation delete-stack --stack-name $STACKNAME
  aws --profile $profile --region $reg cloudformation delete-stack --stack-name $STACKNAME
done

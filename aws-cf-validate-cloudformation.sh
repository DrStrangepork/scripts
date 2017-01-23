#!/usr/bin/env bash
profile=${AWS_DEFAULT_PROFILE:-none}


usage() {
  echo \
"$(tput bold)$(basename ${BASH_SOURCE[0]})$(tput sgr0)
Usage:  Performs a JSON syntax check on TEMPLATE(s), and if it passes uploads it
        to s3://\${bucket}/tmp/ and performs a CloudFormation validation on it.
Example:  $(basename ${BASH_SOURCE[0]}) -b S3BUCKET -t TEMPLATE[,TEMPLATE,...]
Required: -b S3BUCKET -t TEMPLATE
Options:
  -b S3BUCKET   name of S3 bucket (must start with 's3://')
  -t TEMPLATE   comma-delimited list of templates
  -p            AWS profile (default: AWS_DEFAULT_PROFILE or \"none\")
  -h            help"
}


prereq="Prerequisites are missing and must be installed before continuing:\n"
missing_req=false
if ! which aws >/dev/null 2>&1; then
  prereq+="\t'aws' python cli from http://aws.amazon.com/cli/\n"
  missing_req=true
fi
if ! which jq >/dev/null 2>&1; then
  prereq+="\t'jq' from 'yum install jq'\n"
  missing_req=true
fi
if $missing_req; then
  echo -e "Error: $prereq" >&2
  exit 1
fi


[[ "$@" =~ "--help" ]] && { usage | less; exit; }
while getopts ":b:p:t:h" opt; do
  case $opt in
    b)  S3=$(echo "$OPTARG" | tr '[:upper:]' '[:lower:]')
        # S3 must be 's3://' followed by a [a-z0-9]
        if ! expr "$S3" : '\(s3://[a-z0-9]\)' >/dev/null; then
          echo "S3 bucket must begin with \"s3://\""
          exit 1
        fi
        # Append a '/' if missing
        [ "$(echo `expr "$S3" : '.*\(.\)'`)" = "/" ] || S3=$S3/
        # If $S3 contains a '.', use long URL format
        expr "$S3" : '\(.*\..*\)' >/dev/null && URL="https://s3-us-east-1.amazonaws.com/${S3#s3://}" || URL="https://s3.amazonaws.com/${S3#s3://}"
        ;;
    p)  profile=$OPTARG
        ;;
    t)  while IFS=',' read -ra TEMPLATE; do
          for i in "${TEMPLATE[@]}"; do
            TEMPLATES+="$i "
          done
        done <<< "$OPTARG"
        ;;
    h)  usage ; exit
        ;;
    *)  echo "Error: invalid option -$OPTARG" >&2
        usage ; exit 1
        ;;
  esac
done
[[ -n "$STACKNAME" || -n "$TEMPLATES" ]] || { usage; exit 1; }


## MAIN
for CFTemp in $TEMPLATES; do
  [ ! -f $CFTemp ] && { echo " ** $CFTemp does not exit"; exit 1; }
  jq '' $CFTemp > /dev/null || { echo " ** $CFTemp failed json validation"; exit 1; }
done
for CFTemp in $TEMPLATES; do
  aws --profile $profile s3 cp $CFTemp $S3 >/dev/null || exit
  echo "Uploaded $CFTemp to ${URL}$(basename $CFTemp)"
  aws --profile $profile cloudformation validate-template --template-url ${URL}$(basename $CFTemp) --output text
  echo ; echo
done

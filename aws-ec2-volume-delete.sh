#!/usr/bin/env bash
AWSRegs="ap-northeast-1 ap-northeast-2 ap-south-1 ap-southeast-1 ap-southeast-2 ca-central-1 eu-central-1 eu-west-1 eu-west-2 eu-west-3 sa-east-1 us-east-1 us-east-2 us-west-1 us-west-2"
profile=${AWS_DEFAULT_PROFILE:-none}
region=${AWS_DEFAULT_REGION:-us-east-1}
QUIET=false
cnt=0


usage() {
  echo \
"$(tput bold)$(basename ${BASH_SOURCE[0]})$(tput sgr0)
Usage:  Deletes available EC2 volumes
Example:  $(basename ${BASH_SOURCE[0]}) -v vol-12345678,vol-12345679
Required: -v or -d (one required but not both)
Options:
  -d YYYY-MM-DD  deletes all volumes with CreateTime prior to YYYY-MM-DD
  -v VolumeId[,VolumeId,..]   deletes given volumes
  -t            volume-type   (gp2|io1|standard) (default: all)
  -q            quiet (no output)
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
while getopts ":d:pqr:t:v:h" opt; do
  case $opt in
    d)  [ -n "$VIDs" ] && { usage; exit 1; }
        if [[ ! "$OPTARG" =~ 201[0-9]-[0-1][0-9]-[0-3][0-9] ]]; then
          echo "Invalid date: $OPTARG"
          exit 1
        fi
        DATE=$OPTARG
        ;;
    p)  profile=$OPTARG
        ;;
    q)  QUIET=true
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
    t)  if [[ "$OPTARG" == "gp2" || "$OPTARG" == "io1" || "$OPTARG" == "standard" ]]; then
          FILTER+="Name=volume-type,Values=$OPTARG "
        else
          echo "Error: invalid volume type - $reg" >&2
          echo "Valid volume types are: gp2, io1, standard"
          exit 1
        fi
        ;;
    v)  [ -n "$DATE" ] && { usage; exit 1; }
        while IFS=',' read -ra VID; do
          for i in "${VID[@]}"; do
            if [[ ! "$i" =~ vol-[a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9][a-z0-9]$ ]]; then
              echo "Invalid AWS Volume ID: $i"
              exit 1
            fi
            VIDs+="$i "
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
[[ -n "$VIDs" || -n "$DATE" ]] || { usage; exit 1; }


## MAIN
for reg in $regions; do
  $QUIET || echo -e "\n$reg"
  if [[ -n "$VIDs" ]]; then
    IDs=$(aws --profile $profile --region $reg ec2 describe-volumes --filters Name=status,Values=available $FILTER --volume-ids $VIDs --query "sort_by(Volumes, &VolumeId)[].[VolumeId]" --output text)
    [[ -z "$IDs" ]] && { echo "No available volumes found" >&2; continue; }
  elif [[ -n "$DATE" ]]; then
    IDs=$(aws --profile $profile --region $reg ec2 describe-volumes --filters Name=status,Values=available $FILTER --query "sort_by(Volumes, &VolumeId)[?CreateTime<\`${DATE}T00:00:00.000Z\`].[VolumeId]" --output text)
    [[ -z "$IDs" ]] && { echo "No available volumes found prior to ${DATE}T00:00:00.000" >&2; continue; }
  fi
  IDsCount=$(echo $IDs | wc -w)
  $QUIET || echo "$IDsCount volumes to be deleted"
  for VID in $IDs; do
    aws --profile $profile --region $reg ec2 delete-volume --volume-id $VID 2>/dev/null || { echo "Delete failed - $VID" >&2; exit 1; }
    ((cnt++))
    $QUIET || printf "$VID deleted: %4s of %4s\n" $cnt $IDsCount
  done
done

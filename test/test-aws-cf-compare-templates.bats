#!./libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

scr='aws-cf-compare-templates.sh'


@test "Should print help successfully if requested" {
  run $scr -h

  assert_success
  assert_line --partial "Usage:"
}

@test "Should print help if no arguments are provided, and exit unsuccessfully" {
  run $scr

  assert_failure
  assert_line --partial "Usage:"
}

@test "Should print help if an unrecognized option is used, and exit unsuccessfully" {
  run $scr -imaginary-command

  assert_failure
  assert_line --partial "Usage:"
}

@test "Should print help if an unrecognized command is used, and exit unsuccessfully" {
  run $scr imaginary-command

  assert_failure
  assert_line --partial "Usage:"
}


# #!/bin/bash
# AWSRegs="ap-northeast-1 ap-southeast-1 ap-southeast-2 eu-central-1 eu-west-1 sa-east-1 us-east-1 us-west-1 us-east-1"
# profile=${AWS_DEFAULT_PROFILE:-none}
# region=${AWS_DEFAULT_REGION:-us-east-1}
# CLEAN=false
# DIFF=false
#
#
# usage() {
#   echo \
# "$(tput bold)$(basename ${BASH_SOURCE[0]})$(tput sgr0)
# Usage:  Downloads the CloudFormation template of STACKNAME and compares it to
#         the contents of TEMPLATE, and the results are displayed in
#         vimdiff (or diff if vimdiff not available).
# Example:  $(basename ${BASH_SOURCE[0]}) -s svc-stack -r us-west2 -t svc.json
# Required: -s STACKNAME -t TEMPLATE
# Options:
#   -s STACKNAME  name of stack
#   -t TEMPLATE   name of template
#   -c            cleanup /tmp/ files
#   -d            run diff, not vimdiff
#   -u            if updates were made to either file, save the original to
#                   <filename>.sav and copy the updated version to <filename>
#   -p            AWS profile (default: AWS_DEFAULT_PROFILE or \"none\")
#   -r            region (default: AWS_DEFAULT_REGION or us-east-1)
#   -h            help"
# }
#
#
# prereq="Prerequisites are missing and must be installed before continuing:\n"
# missing_req=false
# if ! python --version >/dev/null 2>&1; then
#   prereq+="\t'python'\n"
#   missing_req=true
# fi
# if ! python -c "import json.tool" 2>/dev/null; then
#   prereq+="\t'python json library'\n"
#   missing_req=true
# fi
# if ! aws --version >/dev/null 2>&1; then
#   prereq+="\t'aws' python cli from http://aws.amazon.com/cli/\n"
#   missing_req=true
# fi
# if $missing_req; then
#   echo -e "Error: $prereq" >&2
#   exit 1
# fi
#
#
# [[ "$*" =~ "--help" ]] && { usage | less; exit; }
# while getopts ":cdp:r:s:t:uh" opt; do
#   case $opt in
#     c)  CLEAN=true
#         ;;
#     d)  DIFF=true
#         ;;
#     p)  profile=$OPTARG
#         ;;
#     r)  region=${OPTARG,,}  # ${OPTARG,,} converts $OPTARG to all lowercase letters
#         FOUND=false
#         for reg in $AWSRegs; do
#           [ "$reg" == "$region" ] && FOUND=true
#         done
#         if ! $FOUND; then
#           echo "Error: invalid region - $reg" >&2
#           echo "Valid regions are: $AWSRegs" | fold -s >&2
#           exit 1
#         fi
#         ;;
#     s)  STKtmp=/tmp/$OPTARG--$region.liveCFtemplate.json
#         STACK=$OPTARG.json
#         if ! aws --profile $profile --region $region cloudformation get-template --stack-name $OPTARG --query 'TemplateBody' >$STACK.tmp; then
#           echo "Error: Failed to retrieve stack $OPTARG in region $region" >&2
#           exit 1
#         fi
#         python -m json.tool $STACK.tmp > $STACK
#         cp $STACK $STKtmp
#         rm $STACK.tmp
#         ;;
#     t)  TARGET=$OPTARG
#         TRGtmp=/tmp/trg--$(basename $TARGET)
#         if [[ ! -s $TARGET ]]; then
#           echo "Error: Missing file $TARGET" >&2
#           exit 1
#         elif ! python -m json.tool $TARGET > $TRGtmp; then
#           echo "Error: $TARGET failed json validation" >&2
#           exit 1
#         fi
#         ;;
#     u)  UPDATE=true
#         ;;
#     h)  usage ; exit
#         ;;
#     *)  echo "Error: invalid option -$OPTARG" >&2
#         usage ; exit 1
#         ;;
#   esac
# done
# [[ -s "$STKtmp" && -s "$TRGtmp" ]] || { usage; exit 1; }
#
#
# ## MAIN
# if ! diff $STKtmp $TRGtmp >/dev/null; then
#   if $DIFF -o [[ ! -x /usr/bin/vimdiff ]]; then
#     diff $STKtmp $TRGtmp
#   else
#     vimdiff $STKtmp $TRGtmp
#     if [ $UPDATE ]; then
#       if ! python -m json.tool $TRGtmp >/dev/null; then
#         echo "Error: $TRGtmp failed json validation" >&2
#         exit 1
#       elif ! diff $STKtmp $STACK >/dev/null; then
#         echo "Changes made to $STKtmp"
#         echo "Backing up $STACK to $STACK.sav"
#         mv $STACK $STACK.sav
#         echo "Copying $STKtmp to $STACK"
#         cp $STKtmp $STACK
#       else
#         echo "No updates made to $STKtmp"
#       fi
#       if ! python -m json.tool $TRGtmp >/dev/null; then
#         echo "Error: $TRGtmp failed json validation" >&2
#         exit 1
#       elif ! diff $TRGtmp $TARGET >/dev/null; then
#         echo "Changes made to $TRGtmp"
#         echo "Backing up $TARGET to $TARGET.sav"
#         mv $TARGET $TARGET.sav
#         echo "Copying $TRGtmp to $TARGET"
#         cp $TRGtmp $TARGET
#       else
#         echo "No updates made to $TRGtmp"
#       fi
#     fi
#   fi
# else
#   echo Templates are identical
# fi
# $CLEAN && rm -f $TRGtmp $STKtmp

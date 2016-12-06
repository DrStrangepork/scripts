#!./libs/bats/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'test_helper'

scr='./MakeKey.sh'

# setup() {
#   setupTestEnv
#   # source $scr
#   # COMP_WORDS=()
# }

# teardown() {
#   teardownTestEnv
# }


@test "Should print help successfully if requested" {
  run $scr -h

  assert_success
  assert_line --partial "Usage:"
}

@test "Should print help if an unrecognized option is used, and exit unsuccessfully" {
  run $scr -imaginary-command

  assert_failure
  assert_line --partial "Usage:"
}

@test "Should print help if an unrecognized command is used, and exit unsuccessfully" {
  skip "TEST NOT ACCOUNTED FOR"
  run $scr imaginary-command

  assert_failure
  assert_line --partial "Usage:"
}

# MakeKey_cert_file_test1


# touch $TEST_DIRECTORY/test.csr

# @test "TEST" {
#   run env | sort >&1
#   # run pwd

#   assert_success
#   assert_line --partial "HOME"
# }


@test "Should print warning if *.csr files found in the current directory, and exit unsuccessfully" {
  skip "TEST NOT ACCOUNTED FOR"
  run $scr
  # touch $TEST_DIRECTORY/test.csr

  # run bash -xc "$TEST_DIRECTORY/$scr"

  assert_failure
  assert_line --partial "Certificate files found"
}

# MakeKey_cert_file_test2

@test "Should print warning if *.key files found in the current directory, and exit unsuccessfully" {
  skip "TEST NOT ACCOUNTED FOR"
  run $scr

  assert_failure
  assert_line --partial "Certificate files found"
}

# MakeKey_cert_file_test3

@test "Should print warning if *passphrase.txt files found in the current directory, and exit unsuccessfully" {
  skip "TEST NOT ACCOUNTED FOR"
  run $scr

  assert_failure
  assert_line --partial "Certificate files found"
}

# MakeKey_cert_file_test4

@test "Should print extended help successfully if requested" {
  run $scr -H

  assert_success
  assert_line --partial "Enter a strong challenge phrase"
}




# #!/usr/bin/env bash
# VERSION=2.0.3
# ORG="TransPerfect"
#
#
# usage() {
#   echo "Usage: MakeKey [-d DOMAIN [-p 'PASSWORD']] [-q] [-o] [-x] [-v] [-z] [-V] [-h] [-H]
# Creates Standard SSL Certificate files for entered domainname
#   -d DOMAIN   = domain for the cert
#   -p PASSWORD = challenge phrase (must be wrapped in single quotes)
#   -q          = quick (auto-generated challenge phrase)
#   -o          = overwrite existing certificate files
#   -x          = create a Standard Extended Validation SSL Certificate
#   -v          = verbose (prints instructions inline)
#   -z          = zip certificate files into <DOMAIN>.zip
#   -V          = prints version and exits
#   -h          = help
#   -H          = extended help"
# }
#
# Help() {
#   echo "Creates an SSL certificate file <DOMAIN>.csr, the private key
# <DOMAIN>.FRM.key in two formats (FRM = rsa & pem), saves the challenge
# phrase '<PASSWORD>' to passphrase.txt, and compresses them into a file
# named <DOMAIN>.zip encrypted with the challenge phrase."
#   echo; pwtext
#   echo; CSRInstruct
# }
#
# pwtext() {
#   echo 'Enter a strong challenge phrase that includes the following:
#   - At least 8 characters
#   - Both upper and lower case characters
#   - At least one numeric character
#   - At least one special characters: ( ~!@#$%^&*()_+`{[}]|<,>.?:;/ )'
# }
#
# CSRInstruct() {
#   echo "To request an SSL certificate,
#   1. Go to the following website: https://certmanager.websecurity.symantec.com/mcelp/enroll/index?jur_hash=87f9eb0238518493dc5d5e4c52effc96
#     - With Standard SSL in the drop-down list, select Go.
#     - Complete the enrollment form, select Apache under Server Platform and then paste the CSR below.
#     - Under Certificate Signature Algorithm, be sure to select the 'SHA-256 with RSA' option.
#     - Use the challenge phrase '<PASSWORD>' for the Challenge Phrase.
#     - Read the Subscriber Agreement and select Accept.
#   2. Confirm the purchase by replying to the email you receive from the SSL Administrator.
#   3. Usually within 24 hours, the SSL Administrator will email the actual cert.
# To apply the cert to a Thor F5 load balancer,
#   1. Create a JIRA ticket: https://intake.tool.s.nokia.com/browse/NET
#     - Attach the SSL certificate, the CSR, password and <DOMAIN>.pem.key.
# To apply the cert to an AWS load balancer,
#   1. From the EC2 Management Console, select the LB you wish to secure and select the Listeners tab
#     - Select HTTPS for the Load Balancer Protocol and click on Select under SSL Certificate
#   2. Fill out the Select Certificate form
#     - Certificate Type:       select Upload new
#     - Certificate Name:       set to <DOMAIN>
#     - Private Key:            <DOMAIN>.rsa.key
#     - Public Key Certificate: cert.cer.txt from SSL Administrator from
#     - Certificate Chain:      \"Intermediate CA Certificates_RSA-SHA256_Standard_SSL-certchain.pem\"
# https://in2.nokia.com/sites/CCOD/teams/social/accesscontrol/Share%20Documents/Intermediate%20CA%20Certificates_RSA-SHA256_Standard_SSL-certchain.pem"
# }
#
# log_msg() {
#     RED=$(tput setaf 1)
#     GREEN=$(tput setaf 2)
#     NORMAL=$(tput sgr0)
#     MSG="$1"
#     STATUS="[OK]"
#     STATUSCOLOR="$GREEN${STATUS}$NORMAL"
#     let COL=$(tput cols)-${#MSG}+${#STATUSCOLOR}-${#STATUS}
#
#     echo -n $MSG
#     printf "%${COL}s\n"  "$STATUSCOLOR"
# }
#
#
# while getopts ":d:p:qoxvzVhH" opt; do
#   case $opt in
#     d)  DN=${OPTARG}
#         ;;
#     o)  OVERWRITE=1
#         ;;
#     p)  if [[ -z "$DN" ]]; then
#           echo "  ** DOMAIN must be entered before PASSWORD"
#           exit 1
#         elif [[ "$QUICK" ]]; then
#           echo "  ** -p cannot be used with -q"
#           exit 1
#         else
#           PW=${OPTARG}
#         fi
#         ;;
#     q)  if [[ "$PW" ]]; then
#           echo "  ** -q cannot be used with -p"
#           exit 1
#         else
#           QUICK=1
#         fi
#         ;;
#     v)  VERBOSE=1
#         ;;
#     x)  EXTENDED=" extended validation"
#         ORG="Nokia Oyj"
#         ;;
#     z)  ZIP=1
#         ;;
#     V)  echo $VERSION
#         exit
#         ;;
#     h)  usage ; exit
#         ;;
#     H)  usage ; Help ; exit
#         ;;
#     *)  usage ; exit 1
#         ;;
#   esac
# done
#
# if [[ $OPTIND -eq 1 && $# -gt 0 ]]; then
#   usage
#   exit
# fi
#
# # Protect existing certificate files!
# if [[ -z "$OVERWRITE" ]]; then
#   shopt -s nullglob
#   if [[ -n $(echo *.csr *.key *passphrase.txt) ]]; then
#     echo "Certificate files found in the current directory. Please handle them."
#     exit 1
#   fi
#   shopt -u nullglob
# fi
#
# # Get DN and PW if blank
# if [[ -z "$DN" ]]; then
#   echo -n "Enter the domain you wish to create a cert for and hit [ENTER]: "
#   read DN
# fi
# [[ -z "$DN" ]] && exit
# if [[ -z "$PW" ]] && [[ -z "$QUICK" ]]; then
#   pwtext
#   echo
#   echo "Enter the challenge phrase for $DN and hit [ENTER],"
#   echo -n "Or just [ENTER] for a random 12-character password: "
#   read PW
# fi
#
# # Generate PW
# if [[ -z "$PW" ]]; then
#   until [[ "$PW" =~ [a-z] ]] && [[ "$PW" =~ [A-Z] ]] && [[ "$PW" =~ [0-9] ]] && [[ "$PW" =~ [~!@#$%^\&*()_+\`{[}]|\<,\>.\?:\;/] ]]; do
#     PW=`< /dev/urandom tr -dc [:graph:] | head -c 12`
#   done
# fi
#
# # Syntax check in PW
# if [[ "${#PW}" -lt "8" ]]; then
#   echo "  ** challenge phrase too short **"
#   PWERR=1
# fi
# if [[ ! "$PW" =~ [a-z] ]] || [[ ! "$PW" =~ [A-Z] ]]; then
#   echo "  ** challenge phrase needs both upper and lower case characters **"
#   PWERR=1
# fi
# if [[ ! "$PW" =~ [0-9] ]]; then
#   echo "  ** challenge phrase needs at least one numeric character **"
#   PWERR=1
# fi
# if [[ ! "$PW" =~ [~!@#$%^\&*()_+\`{[}]|\<,\>.\?:\;/] ]]; then
#   echo "  ** challenge phrase needs at least one special character **"
#   PWERR=1
# fi
#
# if [[ -n "$PWERR" ]]; then
#   echo;echo "Please address errors and try again"
#   exit
# fi
#
# echo -e "\n  FQDN: $DN\n  PASS: $PW\n\n"
#
# # Make the CSR and private key
# echo -n "Create$EXTENDED certificate request files: "
# openssl req -nodes -newkey rsa:2048 -keyout $DN.pem.key -keyform pem -out $DN.csr -subj "/C=US/ST=Massachusetts/L=Maynard/O=$ORG/OU=OneLink/CN=$DN" 2>/dev/null
# if [ "$?" -eq 0 ]; then
#   echo "CHECK"
# else
#   EC=$?
#   echo "  ** ERROR **"
#   echo "     ERRORCODE: $EC"
#   exit $EC
# fi
# echo;cat $DN.csr;echo
#
# # Convert private key in rsa format as well
# echo -n "Create $DN.rsa.key from $DN.pem.key: "
# openssl rsa -in $DN.pem.key > $DN.rsa.key 2> /dev/null
# if [ "$?" -eq 0 ]; then
#   echo "CHECK"
# else
#   EC=$?
#   echo "  ** ERROR **"
#   echo "     ERRORCODE: $EC"
#   exit $EC
# fi
#
# # Save passphrase to a file
# echo -n "Create $DN-passphrase.txt file: "
# echo $PW > $DN-passphrase.txt
# if [ "$?" -eq 0 ]; then
#   echo "CHECK"
# else
#   EC=$?
#   echo "  ** ERROR **"
#   echo "     ERRORCODE: $EC"
#   exit $EC
# fi
#
# # Zip certificate files
# if [[ -n "$ZIP" ]]; then
#   echo -n "Create zip file $DN.zip: "
#   zip -q -P $PW $DN.zip $DN.csr $DN.*.key $DN-passphrase.txt
#   if [ "$?" -eq 0 ]; then
#     echo "CHECK"
#     echo "  ** $DN.zip is encrypted with string '$PW'"
#   else
#     EC=$?
#     echo "  ** ERROR **"
#     echo "     ERRORCODE: $EC"
#     exit $EC
#   fi
# fi
#
# [[ -z "$VERBOSE" ]] || CSRInstruct
#
# [[ -z "$ZIP" ]] && exit
# echo "Cleaning up..."
# rm $DN.csr $DN.*.key $DN-passphrase.txt
#

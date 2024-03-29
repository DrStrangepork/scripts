# scripts [![Build Status](https://travis-ci.org/DrStrangepork/scripts.svg?branch=master)](https://travis-ci.org/DrStrangepork/scripts)

Helpful scripts I've written for various reasons

- aws-cf-compare-templates.sh
  - Downloads the CloudFormation template of STACKNAME and compares it to the contents of TEMPLATE, and the results are displayed in vimdiff (or diff if vimdiff not available).
- aws-cf-create-stack.sh
  - Creates CloudFormation stack STACKNAME in region(s) REGION\[,REGION,...] using template TEMPLATE
- aws-cf-delete-stack.sh
  - Deletes CloudFormation stack STACKNAME from region(s) REGION\[,REGION,...]
- aws-cf-latest-update.sh
  - Returns the date of the most recent update to the CloudFormation template of STACKNAME (date is in UTC)
- aws-cf-update-stack.sh
  - Updates CloudFormation stack STACKNAME in region(s) REGION\[,REGION,...] with template TEMPLATE
- aws-cf-validate-cloudformation.sh
  - Performs a JSON syntax check on TEMPLATE(s), and if it passes uploads it to s3://\${bucket}/tmp/ and performs a CloudFormation validation on it.
    - Requires [jq](https://stedolan.github.io/jq/)
- aws-cw-alarms-with-missing-dimensions.py
  - Reports and optionally deletes CloudWatch alarms that monitor non-existent resources
  - Requires `boto3`: `pip install -r requirements.txt`
- aws-ec2-terminate-instance.sh
  - Deletes EC2 instance based on lookup of InstanceId or PublicDnsName and deletes its rootDeviceName volume
- aws-ec2-volume-delete.sh
  - Deletes available EC2 volumes
- aws-r53-dynamic-update.sh
  - Use to automatically update a record set in AWS Route 53 whenever your IP changes (good for home-based domains that use DHCP (Verizon FIOS, Comcast, etc))
- ~~brew-full-upgrade.sh~~
  - ~~Updates brew and then upgrades any updated formulae and casks~~
  - Retired as `brew` now does natively everything this script managed
- compare-json.sh
  - Compares the contents of two JSON files, and the results are displayed in vimdiff (or diff if vimdiff not available).
- decode.py
  - URL decodes expired AWS console URLs (URLs reformatted after logout)
- git-commit-dates.sh
  - Resets the timestamps of all files in a git repo to their commit dates
- nmap-report.sh
  - Performs a port scan on a given target and saves an HTML report to ./nmap-report.html
- awscp.py
  - Copies a source AWS credentials profile to a target profile of a different name

## Contributors

Simple instructions for testing:

1. `git clone` the repo
1. `git submodule update --init --recursive`
1. `./test.sh`

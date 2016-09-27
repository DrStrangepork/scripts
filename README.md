# scripts
Helpful scripts I've written for various reasons

- aws-cf-compare-templates.sh
    + Downloads the CloudFormation template of STACKNAME and compares it to the contents of TEMPLATE, and the results are displayed in vimdiff (or diff if vimdiff not available).
- aws-cf-create-stack.sh
    + Creates CloudFormation stack STACKNAME in region(s) REGION[,REGION,...]using template TEMPLATE
- aws-cf-delete-stack.sh
    + eletes CloudFormation stack STACKNAME from region(s) REGION[,REGION,...]
- aws-cf-latest-update.sh
    + Returns the date of the most recent update to the CloudFormation template of STACKNAME (date is in UTC)
- aws-cf-update-stack.sh
    + Updates CloudFormation stack STACKNAME in region(s) REGION[,REGION,...]with template TEMPLATE
- aws-cf-validate-cloudformation.sh
    + Performs a JSON syntax check on TEMPLATE(s), and if it passes uploads it to s3://\${bucket}/tmp/ and performs a CloudFormation validation on it.
        * Requires [jq](https://stedolan.github.io/jq/)
- aws-r53-dynamic-update.sh
    + Use to automatically update a record set in AWS Route 53 whenever your IP changes (good for home-based domains that use DHCP (Verizon FIOS, Comcast, etc))
- brew-cask-upgrade.sh
    + Upgrades brew casks
- brew-full-upgrade.sh
    + Updates brew and then upgrades any updated formulae and casks
- compare-json.sh
    + Compares the contents of two JSON files, and the results are displayed in vimdiff (or diff if vimdiff not available).

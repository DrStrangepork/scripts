#!/usr/bin/env python3
import datetime
import json
import pdb
import pprint
import boto3
import botocore.exceptions


def awsacct():
    return boto3.client('sts').get_caller_identity().get('Account')


def awsalias():
    return boto3.client('iam').list_account_aliases()['AccountAliases'][0]


def jdumps(dict):
    print(json.JSONEncoder(default=str, sort_keys=True).encode(dict))


def pp(dict):
    pprint.PrettyPrinter(indent=2).pprint(dict)


# for key, value in sorted(botocore.exceptions.__dict__.items()):
#     if isinstance(value, type):
#         print(key)

try:
    ec2 = boto3.client('ec2')
except botocore.exceptions.NoRegionError:
    print('No active AWS profile')
    pass
now = datetime.datetime.now()

pdb.set_trace()
# dir() to print all of the attributes of a Python object
# vars() to print all of the instance attributes and their values of a Python object

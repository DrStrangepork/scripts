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


# https://stackoverflow.com/questions/33068055/how-to-handle-errors-with-boto3/33663484#33663484
def awserrors():
    print(
        f"Errors: {[e for e in dir(botocore.exceptions) if e.endswith('Error')]}\n"
        + f"Exceptions: {[e for e in dir(botocore.exceptions) if not e.endswith('Error') and e[0].isupper()]}")
    # for key, value in sorted(botocore.exceptions.__dict__.items()):
    #     if isinstance(value, type):
    #         print(key)


def clientexceptions(client):
    return [e for e in dir(client.exceptions) if e.endswith('Exception')]
    # [e for e in dir(client.exceptions) if not e.endswith('Exception') and e[0].isupper()] = ['ClientError']


def jdumps(dict):
    print(json.JSONEncoder(default=str, sort_keys=True).encode(dict))


def pp(dict):
    pprint.PrettyPrinter(indent=2).pprint(dict)


try:
    ec2 = boto3.client('ec2')
except botocore.exceptions.NoRegionError:
    print('No active AWS profile')
    pass
now = datetime.datetime.now()
print(
    'awsacct(): print AWS account number\n'
    'awsalias(): print AWS account alias\n'
    'awserrors(): print generic botocore exceptions\n'
    'clientexceptions(client): print client-specific botocore exceptions\n'
    'jdumps(json): print datetime-compatible, sorted JSON\n'
    'pp(json): PrettyPrint JSON'
)
pdb.set_trace()
# dir() to print all of the attributes of a Python object
# vars() to print all of the instance attributes and their values of a Python object

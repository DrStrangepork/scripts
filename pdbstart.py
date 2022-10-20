#!/usr/bin/env python3
import datetime
import json
import pdb
import boto3
from botocore.exceptions import ClientError, WaiterError


def jdumps(dict):
    print(json.JSONEncoder(default=str, sort_keys=True).encode(dict))


ec2 = boto3.client('ec2')
now = datetime.datetime.now()

pdb.set_trace()
# dir() to print all of the attributes of a Python object
# vars() to print all of the instance attributes and their values of a Python object

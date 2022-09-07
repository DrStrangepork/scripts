#!/usr/bin/env python3
import json
import boto3
from botocore.exceptions import ClientError, WaiterError
import pdb


def jdumps(dict):
    print(json.JSONEncoder(default=str, sort_keys=True).encode(dict))


ec2 = boto3.client('ec2')

pdb.set_trace()

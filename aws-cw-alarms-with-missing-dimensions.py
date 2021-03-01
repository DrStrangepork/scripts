#!/usr/bin/env python3
import argparse
import re
import boto3
from botocore.exceptions import ClientError


class Debug(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        import pdb; pdb.set_trace()


# MAIN
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="CloudWatch Alarm Auditing")
    parser.add_argument('-d', '--delete',
                        action='store_true',
                        help='Delete alarms with missing dimensions')
    parser.add_argument('-v', '--verbose',
                        action='store_true',
                        help='Display all alarms')
    parser.add_argument('--debug',
                        action=Debug, nargs=0,
                        help=argparse.SUPPRESS)
    args = parser.parse_args()

    cloudwatch = boto3.client('cloudwatch')
    paginator = cloudwatch.get_paginator('describe_alarms')
    for response in paginator.paginate():
        for alarm in response['MetricAlarms']:
            if not alarm['Dimensions']:
                if args.delete:
                    cloudwatch.delete_alarms(AlarmNames=[alarm['AlarmName']])
                    print("AlarmName \"%s\" deleted" % alarm['AlarmName'])
                else:
                    print("\"%s\": Empty dimensions" % alarm['AlarmName'])
                break
            for dimension in alarm['Dimensions']:
                if dimension['Name'] in ("MountPath", "Filesystem"):
                    # Filesystem checks have multiple keys, skip all but InstanceId
                    pass
                elif dimension['Name'] == 'InstanceId':
                    try:
                        client = boto3.client('ec2')
                        result = client.describe_instances(InstanceIds=[dimension['Value']])
                    except ClientError as e:
                        if 'InvalidInstanceID.NotFound' in str(e):
                            if args.delete:
                                cloudwatch.delete_alarms(AlarmNames=[alarm['AlarmName']])
                                print("AlarmName \"%s\" deleted" % alarm['AlarmName'])
                            else:
                                print("\"%s\": Instance %s not found" % (alarm['AlarmName'], dimension['Value']))
                        else:
                            print(e)
                    break
                elif dimension['Name'] == 'AutoScalingGroupName':
                    try:
                        client = boto3.client('autoscaling')
                        result = client.describe_auto_scaling_groups(AutoScalingGroupNames=[dimension['Value']])
                        if not result['AutoScalingGroups']:
                            if args.delete:
                                cloudwatch.delete_alarms(AlarmNames=[alarm['AlarmName']])
                                print("AlarmName \"%s\" deleted" % alarm['AlarmName'])
                            else:
                                print("\"%s\": AutoScalingGroup %s not found" % (alarm['AlarmName'], dimension['Value']))
                    except ClientError as e:
                        print(e)
                        print("%s: %s" % (alarm['AlarmName'], dimension['Value']))
                elif dimension['Name'] == 'LoadBalancerName':
                    try:
                        client = boto3.client('elb')
                        result = client.describe_load_balancers(LoadBalancerNames=[dimension['Value']])
                        if not result['LoadBalancerDescriptions']:
                            if args.delete:
                                cloudwatch.delete_alarms(AlarmNames=[alarm['AlarmName']])
                                print("AlarmName \"%s\" deleted" % alarm['AlarmName'])
                            else:
                                print("\"%s\": LoadBalancer %s not found" % (alarm['AlarmName'], dimension['Value']))
                    except ClientError as e:
                        if 'LoadBalancerNotFound' in str(e):
                            if args.delete:
                                cloudwatch.delete_alarms(AlarmNames=[alarm['AlarmName']])
                                print("AlarmName \"%s\" deleted" % alarm['AlarmName'])
                            else:
                                print("\"%s\": DBInstance %s not found" % (alarm['AlarmName'], dimension['Value']))
                        else:
                            print(e)
                            print("%s: %s" % (alarm['AlarmName'], dimension['Value']))
                elif dimension['Name'] == 'LoadBalancer':
                    dimension['Value'] = re.split(r'/', dimension['Value'])[1]
                    try:
                        client = boto3.client('elbv2')
                        result = client.describe_load_balancers(Names=[dimension['Value']])
                        if not result['LoadBalancers']:
                            if args.delete:
                                cloudwatch.delete_alarms(AlarmNames=[alarm['AlarmName']])
                                print("AlarmName \"%s\" deleted" % alarm['AlarmName'])
                            else:
                                print("\"%s\": LoadBalancer %s not found" % (alarm['AlarmName'], dimension['Value']))
                    except ClientError as e:
                        if 'LoadBalancerNotFound' in str(e):
                            if args.delete:
                                cloudwatch.delete_alarms(AlarmNames=[alarm['AlarmName']])
                                print("AlarmName \"%s\" deleted" % alarm['AlarmName'])
                            else:
                                print("\"%s\": DBInstance %s not found" % (alarm['AlarmName'], dimension['Value']))
                        else:
                            print(e)
                            print("%s: %s" % (alarm['AlarmName'], dimension['Value']))
                elif dimension['Name'] == 'DBInstanceIdentifier':
                    try:
                        client = boto3.client('rds')
                        result = client.describe_db_instances(DBInstanceIdentifier=dimension['Value'])
                        if not result['DBInstances']:
                            if args.delete:
                                cloudwatch.delete_alarms(AlarmNames=[alarm['AlarmName']])
                                print("AlarmName \"%s\" deleted" % alarm['AlarmName'])
                            else:
                                print("\"%s\": DBInstance %s not found" % (alarm['AlarmName'], dimension['Value']))
                    except ClientError as e:
                        if 'DBInstanceNotFound' in str(e):
                            if args.delete:
                                cloudwatch.delete_alarms(AlarmNames=[alarm['AlarmName']])
                                print("AlarmName \"%s\" deleted" % alarm['AlarmName'])
                            else:
                                print("\"%s\": DBInstance %s not found" % (alarm['AlarmName'], dimension['Value']))
                        else:
                            print(e)
                            print("%s: %s" % (alarm['AlarmName'], dimension['Value']))
                elif dimension['Name'] == 'TableName':
                    try:
                        client = boto3.client('dynamodb')
                        result = client.describe_table(TableName=dimension['Value'])
                        if not result['Table']:
                            if args.delete:
                                cloudwatch.delete_alarms(AlarmNames=[alarm['AlarmName']])
                                print("AlarmName \"%s\" deleted" % alarm['AlarmName'])
                            else:
                                print("\"%s\": Table %s not found" % (alarm['AlarmName'], dimension['Value']))
                    except ClientError as e:
                        print(e)
                        print("%s: %s" % (alarm['AlarmName'], dimension['Value']))
                elif args.verbose:
                        print("** UNHANDLED RESOURCE ** \"%s\": %s" % (alarm['AlarmName'], str(dimension)))

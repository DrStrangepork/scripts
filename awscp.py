#!/usr/bin/env python3
import argparse
import configparser
import os


def copy_aws_profile():
    parser = argparse.ArgumentParser(description='Copy AWS credentials profile')
    parser.add_argument('-s', '--source', required=True, help='Source profile')
    parser.add_argument('-t', '--target', required=True, help='Target/New profile')
    parser.add_argument('-r', '--use-target-region', action='store_true', help='Maintain existing AWS region of target profile')
    parser.add_argument('-v', '--verbose', action='store_true')
    args = parser.parse_args()

    aws_config_file = os.path.expanduser('~/.aws/config')
    aws_credentials_file = os.path.expanduser('~/.aws/credentials')
    source_profile_section = f'profile {args.source}'
    target_profile_section = f'profile {args.target}'

    # Load the AWS credentials files
    config = configparser.ConfigParser(); config.read(aws_config_file)
    creds = configparser.ConfigParser(); creds.read(aws_credentials_file)

    # Check if the source profile exists
    if source_profile_section not in config.sections():
        print(f"Source profile '{args.source}' does not exist in {aws_config_file} file")
        return
    if args.source not in creds.sections():
        print(f"Source profile '{args.source}' does not exist in {aws_credentials_file} file")
        return

    # Copy the source profile to a target profile in the config file
    if target_profile_section not in config.sections():
        config.add_section(target_profile_section)
        config[target_profile_section]['region'] = config['default']['region']
    for key, value in config.items(source_profile_section):
        if args.use_target_region and key == 'region': continue
        if key == 'profile': continue
        config.set(target_profile_section, key, value)

    # Save the changes to the AWS config file
    with open(aws_config_file, 'w') as config_file:
        config.write(config_file)

    if args.verbose: print(f"Profile '{args.source}' copied as '{args.target}' in the AWS config file.")

    # Copy the source profile to a target profile in the credentials file
    if args.target not in creds.sections():
        creds.add_section(args.target)
    for key, value in creds.items(args.source):
        creds.set(args.target, key, value)

    # Save the changes to the AWS credentials file
    with open(aws_credentials_file, 'w') as config_file:
        creds.write(config_file)

    if args.verbose: print(f"Profile '{args.source}' copied as '{args.target}' in the AWS credentials file.")


if __name__ == "__main__":
    copy_aws_profile()

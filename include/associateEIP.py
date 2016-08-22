
import boto3
import json
from sys import exit

ec2 = boto3.client('ec2')
ec2r = boto3.resource('ec2')


def availableEIPs():
    available_eips = []
    for addr in ec2.describe_addresses()['Addresses']:
        if 'AssociationId' in addr:
            continue
        available_eips.append(addr)
    return available_eips


def expectedEIP(instance_id):
    tags = ec2r.Instance(instance_id).tags
    for tag in tags:
        if tag['Key'] == 'expected_EIPs':
            return tag['Value']


def lambda_handler(event, context):
    sns_json = json.loads(event['Records'][0]['Sns']['Message'])
    instance_id = sns_json['EC2InstanceId'].strip()
    print instance_id
    tag_ips = expectedEIP(instance_id)
    print tag_ips
    available_eips = availableEIPs()
    print available_eips
    expected_eips = tag_ips.split(',')
    print expected_eips

    if len(available_eips) < 1:
        exit('Error: no available EIPs')
    alloc_id = None

    for eip in available_eips:
        if eip['PublicIp'] in expected_eips:
            alloc_id = eip['AllocationId']
            print alloc_id
            break

    if not alloc_id:
        exit('Error: Expected EIP not available')
    else:
        resp = ec2.associate_address(InstanceId=instance_id,
                                     AllocationId=alloc_id)

    if 'AssociationId' not in resp:
        exit('Error: EIP failed to associate.')
    else:
        return "Association complete"

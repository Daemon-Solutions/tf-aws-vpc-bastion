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


def privateSubnets(instance_id):
    tags = ec2r.Instance(instance_id).tags
    for tag in tags:
        if tag['Key'] == 'private_subnets':
            return tag['Value']


def matchAZ(instance_id, subnet_ids):
    i_az = ec2r.Instance(instance_id).placement['AvailabilityZone']
    for subnet_id in subnet_ids:
        s_az = ec2r.Subnet(subnet_id).availability_zone
        if s_az == i_az:
            return subnet_id
    return None


def associatedRouteTableId(subnet_id):
    routeTable_id = ec2.describe_route_tables(Filters=[
        {
            'Name': 'association.subnet-id',
            'Values': [subnet_id]
        }
        ]
        )['RouteTables'][0]['RouteTableId']
    return routeTable_id


def cleanRoutes(routeTable_id):
    routes = ec2r.RouteTable(routeTable_id).routes
    for route in routes:
        if route.destination_cidr_block == '0.0.0.0/0':
            route.delete()


def addRoute(instance_id, subnet_id):
    routeTable_id = associatedRouteTableId(subnet_id)
    cleanRoutes(routeTable_id)
    ec2.create_route(RouteTableId=routeTable_id, InstanceId=instance_id,
                     DestinationCidrBlock='0.0.0.0/0')


def doAssociation(instance_id):
    tag_subnets = privateSubnets(instance_id)
    tag_ips = expectedEIP(instance_id)
    available_eips = availableEIPs()
    expected_eips = tag_ips.split(',')
    subnet_ids = tag_subnets.split(',')
    subnet_id = matchAZ(instance_id, subnet_ids)

    if len(available_eips) < 1:
        return False
    alloc_id = None

    for eip in available_eips:
        if eip['PublicIp'] in expected_eips:
            alloc_id = eip['AllocationId']
            break

    if not alloc_id:
        return False
    else:
        resp = ec2.associate_address(InstanceId=instance_id,
                                     AllocationId=alloc_id)

    addRoute(instance_id, subnet_id)

    if 'AssociationId' not in resp:
        return False
    else:
        return True


def lambda_handler(event, context):
    sns_json = json.loads(event['Records'][0]['Sns']['Message'])
    event_type = sns_json['Event']
    if event_type == "autoscaling:TEST_NOTIFICATION":
        asg = boto3.client('autoscaling')
        asi = "AutoScalingInstances"
        instance_ids = [
            i['InstanceId']
            for i in asg.describe_auto_scaling_instances()[asi]
            if i['AutoScalingGroupName'] == sns_json['AutoScalingGroupName']
        ]
    else:
        instance_ids = [ sns_json['EC2InstanceId'].strip() ]

    associations = ""
    note = "InstanceId"
    win = "associated.\n"
    lose = "failed to associate.\n"
    for instance_id in instance_ids:
        response = doAssociation(instance_id)
        if response:
            associations += "{} {} {}".format(note, instance_id, win)
        else:
            associations += "{} {} {}".format(note, instance_id, lose)
    return associations

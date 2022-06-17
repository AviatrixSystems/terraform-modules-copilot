import logging
import sys
import boto3
from botocore.exceptions import ClientError


class AviatrixException(Exception):
    def __init__(self, message="Aviatrix Error Message: ..."):
        super(AviatrixException, self).__init__(message)


def revoke_ingress_rules(
        access_key,
        security_key,
        ip,
        region,
        rules,
):
    ec2 = boto3.client('ec2', aws_access_key_id=access_key, aws_secret_access_key=security_key, region_name=region)

    filters = [{
        'Name': 'ip-address',
        'Values': [ip],
    }]

    instance = ec2.describe_instances(Filters=filters)
    security_groups = instance['Reservations'][0]['Instances'][0]['SecurityGroups']

    rule_string = 'AviatrixSecurityGroup'

    security_group_id = ''
    for sg in security_groups:
        if rule_string in sg['GroupName']:
            security_group_id = sg['GroupId']
    if not security_group_id:
        raise AviatrixException(
            message="Could not get the security group ID.",
        )

    try:
        response = ec2.revoke_security_group_ingress(
            GroupId=security_group_id,
            IpPermissions=rules)
    except ClientError:
        logging.info('Could not revoke ingress security group rule.')
        raise
    else:
        return response


def function_handler(event):
    access_key = event["access_key"]
    security_key = event["security_key"]

    controller_public_ip = event["controller_public_ip"]
    controller_region = event["controller_region"]

    main_copilot_public_ip = event["main_copilot_public_ip"]
    node_copilot_public_ips = event["node_copilot_public_ips"]
    all_copilot_public_ips = [main_copilot_public_ip] + node_copilot_public_ips

    ########################################################################################
    # Clean up the security group rules used for copilot cluster deployment in controller  #
    ########################################################################################
    logging.info("CLEANING UP START: Clean up the security group rules in controller.")

    # modify controller security rule

    controller_rules = []

    for ip in all_copilot_public_ips:
        controller_rules.append(
            {
                "IpProtocol": "tcp",
                "FromPort": 443,
                "ToPort": 443,
                "IpRanges": [{
                    "CidrIp": ip + "/32"
                }]
            }
        )

    revoke_ingress_rules(
        access_key=access_key,
        security_key=security_key,
        ip=controller_public_ip,
        region=controller_region,
        rules=controller_rules
    )

    logging.info("CLEANING UP ENDED: Cleaned up the security group rules in controller.")


if __name__ == '__main__':
    logging.basicConfig(
        format="%(asctime)s copilot-cluster-clean--- %(message)s", level=logging.INFO
    )

    access_key = sys.argv[1]
    security_key = sys.argv[2]
    controller_public_ip = sys.argv[3]
    controller_region = sys.argv[4]
    main_copilot_public_ip = sys.argv[5]
    node_copilot_public_ips = sys.argv[6].split(",")

    event = {
        "access_key": access_key,
        "security_key": security_key,
        "controller_public_ip": controller_public_ip,
        "controller_region": controller_region,
        "main_copilot_public_ip": main_copilot_public_ip,
        "node_copilot_public_ips": node_copilot_public_ips,
    }

    try:
        function_handler(event)
    except Exception as e:
        logging.exception("")
    else:
        logging.info("Security group rules used for CoPilot cluster deployment have been cleaned up.")

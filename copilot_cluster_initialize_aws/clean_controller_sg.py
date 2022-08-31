import logging
import sys
import boto3
from botocore.exceptions import ClientError


class AviatrixException(Exception):
    def __init__(self, message="Aviatrix Error Message: ..."):
        super(AviatrixException, self).__init__(message)


def revoke_ingress_rules(
        aws_access_key,
        aws_secret_access_key,
        private_ip,
        region,
        rules,
        sg_name
):
    ec2 = boto3.client('ec2', aws_access_key_id=aws_access_key, aws_secret_access_key=aws_secret_access_key, region_name=region)

    filters = [{
        'Name': 'private-ip-address',
        'Values': [private_ip],
    }]

    instance = ec2.describe_instances(Filters=filters)
    security_groups = instance['Reservations'][0]['Instances'][0]['SecurityGroups']

    # rule_string = 'AviatrixSecurityGroup'

    security_group_id = ''
    for sg in security_groups:
        if sg_name in sg['GroupName']:
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
    aws_access_key = event["aws_access_key"]
    aws_secret_access_key = event["aws_secret_access_key"]

    controller_private_ip = event["controller_private_ip"]
    controller_region = event["controller_region"]

    main_copilot_public_ip = event["main_copilot_public_ip"]
    node_copilot_public_ips = event["node_copilot_public_ips"]
    all_copilot_public_ips = [main_copilot_public_ip] + node_copilot_public_ips

    main_copilot_private_ip = event["main_copilot_private_ip"]
    node_copilot_private_ips = event["node_copilot_private_ips"]
    all_copilot_private_ips = [main_copilot_private_ip] + node_copilot_private_ips

    private_mode = event["private_mode"]

    controller_sg_name = event["controller_sg_name"]

    ########################################################################################
    # Clean up the security group rules used for copilot cluster deployment in controller  #
    ########################################################################################
    logging.info("CLEANING UP START: Clean up the security group rules in controller.")

    # modify controller security rule

    controller_rules = []

    if private_mode:
        for ip in all_copilot_private_ips:
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
            aws_access_key=aws_access_key,
            aws_secret_access_key=aws_secret_access_key,
            private_ip=controller_private_ip,
            region=controller_region,
            rules=controller_rules,
            sg_name=controller_sg_name
        )
    else:
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

        logging.info(controller_rules)

        revoke_ingress_rules(
            aws_access_key=aws_access_key,
            aws_secret_access_key=aws_secret_access_key,
            private_ip=controller_private_ip,
            region=controller_region,
            rules=controller_rules,
            sg_name=controller_sg_name
        )

    logging.info("CLEANING UP ENDED: Cleaned up the security group rules in controller.")


if __name__ == '__main__':
    logging.basicConfig(
        format="%(asctime)s copilot-cluster-clean--- %(message)s", level=logging.INFO
    )

    i = 1
    aws_access_key = sys.argv[i]
    i += 1
    aws_secret_access_key = sys.argv[i]
    i += 1
    controller_private_ip = sys.argv[i]
    i += 1
    controller_region = sys.argv[i]
    i += 1
    main_copilot_public_ip = sys.argv[i]
    i += 1
    node_copilot_public_ips = sys.argv[i].split(",")
    i += 1
    main_copilot_private_ip = sys.argv[i]
    i += 1
    node_copilot_private_ips = sys.argv[i].split(",")
    i += 1
    private_mode = sys.argv[i]
    i += 1
    controller_sg_name = sys.argv[i]

    event = {
        "aws_access_key": aws_access_key,
        "aws_secret_access_key": aws_secret_access_key,
        "controller_private_ip": controller_private_ip,
        "controller_region": controller_region,
        "main_copilot_public_ip": main_copilot_public_ip,
        "node_copilot_public_ips": node_copilot_public_ips,
        "main_copilot_private_ip": main_copilot_private_ip,
        "node_copilot_private_ips": node_copilot_private_ips,
        "private_mode": True if private_mode == "true" else False,
        "controller_sg_name": controller_sg_name
    }

    try:
        function_handler(event)
    except Exception as e:
        logging.exception("")
    else:
        logging.info("Security group rules used for CoPilot cluster deployment have been cleaned up.")

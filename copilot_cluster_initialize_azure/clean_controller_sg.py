import logging
import sys

from azure.core.exceptions import HttpResponseError
from azure.identity import ClientSecretCredential
from azure.mgmt.network import NetworkManagementClient


class AviatrixException(Exception):
    def __init__(self, message="Aviatrix Error Message: ..."):
        super(AviatrixException, self).__init__(message)


def revoke_ingress_rules(
        subscription_id,
        client_id,
        client_secret,
        tenant_id,
        resource_group_name,
        network_security_group_name,
        security_rule_name
):
    subscription_id = subscription_id
    credentials = ClientSecretCredential(
        client_id=client_id,
        client_secret=client_secret,
        tenant_id=tenant_id
    )

    network_client = NetworkManagementClient(
        credentials,
        subscription_id
    )

    try:
        response = network_client.security_rules.begin_delete(
            resource_group_name,
            network_security_group_name,
            security_rule_name
        )
    except HttpResponseError:
        logging.info('Could not delete ingress security group rule.')
        raise
    else:
        return response


def function_handler(event):
    subscription_id = event["subscription_id"]
    client_id = event["client_id"]
    client_secret = event["client_secret"]
    tenant_id = event["tenant_id"]

    controller_resource_group_name = event["controller_resource_group_name"]
    controller_network_security_group_name = event["controller_network_security_group_name"]
    controller_security_rule_name = event["controller_security_rule_name"]

    ########################################################################################
    # Clean up the security group rules used for copilot cluster deployment in controller  #
    ########################################################################################
    logging.info("CLEANING UP START: Clean up the security group rules in controller.")

    revoke_ingress_rules(
        subscription_id=subscription_id,
        client_id=client_id,
        client_secret=client_secret,
        tenant_id=tenant_id,
        resource_group_name=controller_resource_group_name,
        network_security_group_name=controller_network_security_group_name,
        security_rule_name=controller_security_rule_name
    )

    logging.info("CLEANING UP ENDED: Cleaned up the security group rules in controller.")


if __name__ == '__main__':
    logging.basicConfig(
        format="%(asctime)s copilot-cluster-clean--- %(message)s", level=logging.INFO
    )

    i = 1
    subscription_id = sys.argv[i]
    i += 1
    client_id = sys.argv[i]
    i += 1
    client_secret = sys.argv[i]
    i += 1
    tenant_id = sys.argv[i]
    i += 1
    controller_resource_group_name = sys.argv[i]
    i += 1
    controller_network_security_group_name = sys.argv[i]
    i += 1
    controller_security_rule_name = sys.argv[i]

    event = {
        "subscription_id": subscription_id,
        "client_id": client_id,
        "client_secret": client_secret,
        "tenant_id": tenant_id,
        "controller_resource_group_name": controller_resource_group_name,
        "controller_network_security_group_name": controller_network_security_group_name,
        "controller_security_rule_name": controller_security_rule_name,
    }

    try:
        function_handler(event)
    except Exception as e:
        logging.exception("")
    else:
        logging.info("Security group rules used for CoPilot cluster deployment have been cleaned up.")

import json
import logging
import sys
import time
import traceback
import requests
import boto3
from botocore.exceptions import ClientError


class AviatrixException(Exception):
    def __init__(self, message="Aviatrix Error Message: ..."):
        super(AviatrixException, self).__init__(message)


def add_ingress_rules(
        aws_access_key,
        aws_secret_access_key,
        private_ip,
        region,
        rules,
        sg_name
):
    ec2 = boto3.client('ec2', aws_access_key_id=aws_access_key, aws_secret_access_key=aws_secret_access_key,
                       region_name=region)

    filters = [{
        'Name': 'private-ip-address',
        'Values': [private_ip],
    }]

    instance = ec2.describe_instances(Filters=filters)
    security_groups = instance['Reservations'][0]['Instances'][0]['SecurityGroups']

    security_group_id = ''
    for sg in security_groups:
        if sg_name in sg['GroupName']:
            security_group_id = sg['GroupId']
    if not security_group_id:
        raise AviatrixException(
            message="Could not get the security group ID.",
        )

    try:
        response = ec2.authorize_security_group_ingress(
            GroupId=security_group_id,
            IpPermissions=rules)
    except ClientError:
        logging.info('Could not create ingress security group rule.')
        raise
    else:
        return response


def send_aviatrix_api(
        api_endpoint_url="https://123.123.123.123/v1/api",
        request_method="POST",
        payload=dict(),
        headers=dict(),
        retry_count=5,
        sleep_between_retries=0,
        timeout=None,
        files=dict(),
):
    response = None
    responses = list()
    request_type = request_method.upper()
    response_status_code = -1

    for i in range(retry_count):
        try:
            if request_type == "GET":
                response = requests.get(
                    url=api_endpoint_url, params=payload, headers=headers, verify=False
                )
                response_status_code = response.status_code
            elif request_type == "POST":
                response = requests.post(
                    url=api_endpoint_url, data=payload, headers=headers, verify=False, timeout=timeout, files=files
                )
                response_status_code = response.status_code
            else:
                failure_reason = "ERROR : Bad HTTPS request type: " + request_type
                logging.error(failure_reason)
        except requests.exceptions.Timeout as e:
            logging.exception("WARNING: Request timeout...")
            responses.append(str(e))
        except requests.exceptions.ConnectionError as e:
            logging.exception("WARNING: Server is not responding...")
            responses.append(str(e))
        except Exception as e:
            traceback_msg = traceback.format_exc()
            logging.exception("HTTP request failed")
            responses.append(str(traceback_msg))

        finally:
            if response_status_code == 200:
                return response
            elif response_status_code == 404:
                failure_reason = "ERROR: 404 Not Found"
                logging.error(failure_reason)
            else:
                return response

            # if the response code is neither 200 nor 404, repeat the precess (retry)

            if i + 1 < retry_count:
                logging.info("START: retry")
                logging.info("i == %d", i)
                logging.info("Wait for: %ds for the next retry", sleep_between_retries)
                time.sleep(sleep_between_retries)
                logging.info("ENDED: Wait until retry")
                # continue next iteration
            else:
                failure_reason = (
                        "ERROR: Failed to invoke API at " + api_endpoint_url + ". Exceed the max retry times. "
                        + " All responses are listed as follows :  "
                        + str(responses)
                )
                raise AviatrixException(
                    message=failure_reason,
                )

    return response


def login_controller(
        controller_ip,
        username,
        password,
        hide_password=True,
):
    request_method = "POST"
    data = {
        "action": "login",
        "username": username,
        "password": password
    }

    api_endpoint_url = "https://" + controller_ip + "/v1/api"
    logging.info("API endpoint url is : %s", api_endpoint_url)

    # handle if the hide_password is selected
    if hide_password:
        payload_with_hidden_password = dict(data)
        payload_with_hidden_password["password"] = "************"
        logging.info(
            "Request payload: %s",
            str(json.dumps(obj=payload_with_hidden_password, indent=4)),
        )
    else:
        logging.info("Request payload: %s", str(json.dumps(obj=data, indent=4)))

    # send post request to the api endpoint
    response = send_aviatrix_api(
        api_endpoint_url=api_endpoint_url,
        request_method=request_method,
        payload=data,
        retry_count=12,
        sleep_between_retries=10
    )

    return response


def verify_controller_login_response(response=None):
    # if successfully login
    # response_code == 200
    # api_return_boolean == true
    # response_message = "authorized successfully"

    py_dict = response.json()
    logging.info("Aviatrix API response is %s", str(py_dict))

    response_code = response.status_code
    if response_code != 200:
        err_msg = (
                "Fail to login Aviatrix Controller. The response code is" + response_code
        )
        raise AviatrixException(message=err_msg)

    api_return_boolean = py_dict["return"]
    if api_return_boolean is not True:
        err_msg = "Fail to Login Aviatrix Controller. The Response is" + str(py_dict)
        raise AviatrixException(
            message=err_msg,
        )

    api_return_msg = py_dict["results"]
    expected_string = "authorized successfully"
    if (expected_string in api_return_msg) is not True:
        err_msg = "Fail to Login Aviatrix Controller. The Response is" + str(py_dict)
        raise AviatrixException(
            message=err_msg,
        )


def login_copilot(
        controller_ip,
        copilot_ip,
        username,
        password,
        hide_password=True,
):
    request_method = "POST"
    data = {
        "controllerIp": controller_ip,
        "username": username,
        "password": password
    }

    api_endpoint_url = "https://" + copilot_ip + "/login"
    logging.info("API endpoint url is : %s", api_endpoint_url)

    # handle if the hide_password is selected
    if hide_password:
        payload_with_hidden_password = dict(data)
        payload_with_hidden_password["password"] = "************"
        logging.info(
            "Request payload: %s",
            str(json.dumps(obj=payload_with_hidden_password, indent=4)),
        )
    else:
        logging.info("Request payload: %s", str(json.dumps(obj=data, indent=4)))

    # send post request to the api endpoint
    response = send_aviatrix_api(
        api_endpoint_url=api_endpoint_url,
        request_method=request_method,
        payload=data,
        retry_count=12,
        sleep_between_retries=10
    )

    return response


def init_copilot(
        controller_username,
        controller_password,
        copilot_ip,
        CID,
        hide_password=True
):
    request_method = "POST"
    headers = {
        "content-type": "application/json",
        "cid": CID
    }

    data = {
        "taskserver": {
            "username": controller_username,
            "password": controller_password
        }
    }

    api_endpoint_url = "https://" + copilot_ip + "/v1/api/single-node"
    logging.info("API endpoint url is : %s", api_endpoint_url)

    # handle if the hide_password is selected
    if hide_password:
        payload_with_hidden_password = dict(data)
        payload_with_hidden_password["taskserver"]["password"] = "************"
        logging.info(
            "Request payload: %s",
            str(json.dumps(obj=payload_with_hidden_password, indent=4)),
        )
        data["taskserver"]["password"] = controller_password
    else:
        logging.info("Request payload: %s", str(json.dumps(obj=data, indent=4)))

    # send post request to the api endpoint
    response = send_aviatrix_api(
        api_endpoint_url=api_endpoint_url,
        request_method=request_method,
        payload=json.dumps(data),
        headers=headers
    )

    return response


def get_copilot_init_status(
        copilot_ip,
        CID,
):
    request_method = "GET"
    headers = {
        "content-type": "application/json",
        "cid": CID
    }

    api_endpoint_url = "https://" + copilot_ip + "/v1/api/single-node"
    logging.info("API endpoint url is : %s", api_endpoint_url)

    # send get request to the api endpoint
    response = send_aviatrix_api(
        api_endpoint_url=api_endpoint_url,
        request_method=request_method,
        headers=headers,
    )

    return response


def function_handler(event):
    aws_access_key = event["aws_access_key"]
    aws_secret_access_key = event["aws_secret_access_key"]

    controller_public_ip = event["controller_public_ip"]
    controller_private_ip = event["controller_private_ip"]
    controller_region = event["controller_region"]
    controller_username = event["controller_username"]
    controller_password = event["controller_password"]

    copilot_public_ip = event["copilot_public_ip"]
    copilot_private_ip = event["copilot_private_ip"]
    copilot_username = event["copilot_username"]
    copilot_password = event["copilot_password"]

    private_mode = event["private_mode"]

    controller_sg_name = event["controller_sg_name"]

    controller_login_ip = controller_private_ip if private_mode else controller_public_ip
    copilot_login_ip = copilot_private_ip if private_mode else copilot_public_ip

    ###########################################################################
    # Step 1: Modify the security groups for controller and copilot instances #
    ###########################################################################
    logging.info("STEP 1 START: Modify the security groups for controller and copilot instances.")

    # modify controller security rule
    controller_rules = []

    if private_mode:
        controller_rules.append(
            {
                "IpProtocol": "tcp",
                "FromPort": 443,
                "ToPort": 443,
                "IpRanges": [{
                    "CidrIp": copilot_private_ip + "/32"
                }]
            }
        )

        add_ingress_rules(
            aws_access_key=aws_access_key,
            aws_secret_access_key=aws_secret_access_key,
            private_ip=controller_private_ip,
            region=controller_region,
            rules=controller_rules,
            sg_name=controller_sg_name
        )
    else:
        controller_rules.append(
            {
                "IpProtocol": "tcp",
                "FromPort": 443,
                "ToPort": 443,
                "IpRanges": [{
                    "CidrIp": copilot_public_ip + "/32"
                }]
            }
        )

        add_ingress_rules(
            aws_access_key=aws_access_key,
            aws_secret_access_key=aws_secret_access_key,
            private_ip=controller_private_ip,
            region=controller_region,
            rules=controller_rules,
            sg_name=controller_sg_name
        )

    # logging.info(controller_rules)

    logging.info("STEP 1 ENDED: Modified the security groups for controller and copilot instances.")

    ###################################
    # Step 2: Try to login controller #
    ###################################
    logging.info("STEP 2 START: Login controller.")

    response = login_controller(
        controller_ip=controller_login_ip,
        username=controller_username,
        password=controller_password
    )

    verify_controller_login_response(response=response)

    logging.info("STEP 2 ENDED: Logged into controller.")

    ##########################################################
    # Step 3: Try to login copilot. Retry every 10s for 2min #
    ##########################################################
    logging.info("STEP 3 START: Try to login copilot. Retry every 10s for 2min.")

    # copilot_login_driver(controller_ip=controller_login_ip, login_info=login_info)
    login_copilot(
        controller_ip=controller_login_ip,
        copilot_ip=copilot_login_ip,
        username=copilot_username,
        password=copilot_password
    )

    logging.info("STEP 3 ENDED: Logged into copilot.")

    #######################################
    # Step 4: Login controller to get CID #
    #######################################
    logging.info("STEP 4 START: Login controller to get CID.")

    response = login_controller(
        controller_ip=controller_login_ip,
        username=controller_username,
        password=controller_password
    )

    verify_controller_login_response(response=response)
    CID = response.json()["CID"]

    logging.info("STEP 4 ENDED: Logged into controller and got CID.")

    ##########################################
    # Step 5: Call API to initialize copilot #
    ##########################################
    logging.info("STEP 5 START: Call API to initialize copilot.")

    response = init_copilot(
        controller_username=controller_username,
        controller_password=controller_password,
        copilot_ip=copilot_login_ip,
        CID=CID
    )

    if response.status_code != 200:
        raise AviatrixException(message="Initialization API call failed")

    logging.info("STEP 5 ENDED: Called API to initialize copilot.")

    #######################################
    # Step 6: Check initialization status #
    #######################################
    logging.info("STEP 6 START: Check initialization status.")

    retry_count = 30
    sleep_between_retries = 30

    for i in range(retry_count):
        response = get_copilot_init_status(
            copilot_ip=copilot_login_ip,
            CID=CID
        )

        py_dict = response.json()
        api_return_msg = py_dict.get("status")
        logging.info(py_dict.get("message"))

        if api_return_msg == "failed":
            raise AviatrixException(message="Initialization failed.")
        elif api_return_msg == "done":
            return

        if i + 1 < retry_count:
            logging.info("START: retry")
            logging.info("i == %d", i)
            logging.info("Wait for: %ds for the next retry", sleep_between_retries)
            time.sleep(sleep_between_retries)
            logging.info("ENDED: Wait until retry")
            # continue next iteration
        else:
            raise AviatrixException(
                message="Exceed the max retry times. Initialization still not done.",
            )

    logging.info("STEP 6 ENDED: Initialization status check is done.")


if __name__ == '__main__':
    logging.basicConfig(
        format="%(asctime)s copilot-simple-init--- %(message)s", level=logging.INFO
    )

    i = 1
    aws_access_key = sys.argv[i]
    i += 1
    aws_secret_access_key = sys.argv[i]
    i += 1
    controller_public_ip = sys.argv[i]
    i += 1
    controller_private_ip = sys.argv[i]
    i += 1
    controller_region = sys.argv[i]
    i += 1
    controller_username = sys.argv[i]
    i += 1
    controller_password = sys.argv[i]
    i += 1
    copilot_public_ip = sys.argv[i]
    i += 1
    copilot_private_ip = sys.argv[i]
    i += 1
    copilot_username = sys.argv[i]
    i += 1
    copilot_password = sys.argv[i]
    i += 1
    private_mode = sys.argv[i]
    i += 1
    controller_sg_name = sys.argv[i]

    event = {
        "aws_access_key": aws_access_key,
        "aws_secret_access_key": aws_secret_access_key,
        "controller_public_ip": controller_public_ip,
        "controller_private_ip": controller_private_ip,
        "controller_region": controller_region,
        "controller_username": controller_username,
        "controller_password": controller_password,
        "copilot_public_ip": copilot_public_ip,
        "copilot_private_ip": copilot_private_ip,
        "copilot_username": copilot_username,
        "copilot_password": copilot_password,
        "private_mode": True if private_mode == "true" else False,
        "controller_sg_name": controller_sg_name,
    }

    try:
        function_handler(event)
    except Exception as e:
        logging.exception("")
    else:
        logging.info("Aviatrix Copilot has been initialized successfully.")

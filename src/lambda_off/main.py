# Tell python to include the package directory
import os
import sys
import json
import boto3
import logging

# Set structured JSON logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Instance ID of cloud gamer instance
instance_id = os.environ["INSTANCE_ID"]
# Create boto3 ec2 object
ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    """Shuts down the cloug gamer instance.
    The InstanceID is read from the environment variable 'INSTANCE_ID'.
    """
    try:
        # Start instance with InstanceID
        ec2_response = ec2.stop_instances(InstanceIds=[instance_id])
        # Print EC2 response
        print(ec2_response)
        logger.info(ec2_response)
        message = "Okay. The Cloud gaming rig is turning off."
        status_code = 200
    except:
        #print(ec2_response)
        logger.error(ec2_response)
        message = f"Sorry, I couldn't do that. The instance is probably in a stopping state."
        status_code = 500
    
    response = {
        "statusCode": status_code,
        "headers": {},
        "body": json.dumps(message),
        "isBase64Encoded": False
    }
    return response
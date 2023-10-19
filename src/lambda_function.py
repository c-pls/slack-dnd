import os
import boto3
import json
import requests


ssm_client = boto3.client('ssm')

parameter_name = os.environ['SLACK_TOKEN_NAME']


def lambda_handler(event, context):
    slack_set_dnd_endpoint = "https://slack.com/api/dnd.setSnooze"
    try:
        # Use the get_parameter function to retrieve the parameter's value
        response = ssm_client.get_parameter(
            Name=parameter_name,
            WithDecryption=True  # Set to True if the parameter is encrypted
        )

        slack_token = response['Parameter']['Value']

        payload = {
            "num_minutes": "60",
        }

        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {slack_token}"
        }
        # Send the POST request using the requests library
        response = requests.post(
            slack_set_dnd_endpoint, headers=headers, json=payload)

        # Log the response from the API
        print('Response from the API:', response.text)

        # Return a success response
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'POST request sent successfully'})
        }

    except ssm_client.exceptions.ParameterNotFound:
        print(f"Parameter {parameter_name} not found.")
    except Exception as e:
        print(f"An error occurred: {str(e)}")

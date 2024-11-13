import base64
import boto3
import json
import random
import os

# Initialize AWS clients
bedrock_client = boto3.client("bedrock-runtime", region_name="us-east-1")
s3_client = boto3.client("s3")

# Model ID and Bucket name environment variables
MODEL_ID = "amazon.titan-image-generator-v1"
BUCKET_NAME = os.environ["BUCKET_NAME"]

def lambda_handler(event, context):
    # Loop through all SQS records in the event
    for record in event["Records"]:
        try:
            # Extract the SQS message body
            prompt = record["body"]
            print(f"Processing SQS message with prompt: {prompt}")
            
            # Generate a random seed and S3 path for the image
            seed = random.randint(0, 2147483647)
            s3_image_path = f"ka37/images/titan_{seed}.png"
            print(f"Generated S3 image path: {s3_image_path}")

            # Prepare the request payload for image generation
            native_request = {
                "taskType": "TEXT_IMAGE",
                "textToImageParams": {"text": prompt},
                "imageGenerationConfig": {
                    "numberOfImages": 1,
                    "quality": "standard",
                    "cfgScale": 8.0,
                    "height": 512,
                    "width": 512,
                    "seed": seed,
                },
            }

            # Invoke the Bedrock model
            print("Invoking Bedrock model with payload:", native_request)
            response = bedrock_client.invoke_model(
                modelId=MODEL_ID,
                body=json.dumps(native_request)
            )

            # Read and decode the model response
            model_response = json.loads(response["body"].read())
            base64_image_data = model_response["images"][0]
            image_data = base64.b64decode(base64_image_data)
            print("Image generated successfully.")

            # Upload the generated image to S3
            print(f"Uploading image to S3 bucket: {BUCKET_NAME}, path: {s3_image_path}")
            s3_client.put_object(Bucket=BUCKET_NAME, Key=s3_image_path, Body=image_data)
            print("Image uploaded to S3 successfully.")

        except Exception as e:
            # Log any error that occurs during processing
            print(f"Error processing message from SQS: {e}")

    return {
        "statusCode": 200,
        "body": json.dumps("Image generation and upload completed")
    }

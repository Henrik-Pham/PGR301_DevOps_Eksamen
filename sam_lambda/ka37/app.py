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
BUCKET_NAME = os.environ.get("BUCKET_NAME")
CANDIDATE_NUMBER = os.environ.get("CANDIDATE_NUMBER")

def lambda_handler(event, context):
    print("Starting lambda_handler")
    
    # Debug: Check if environment variables are set
    if not BUCKET_NAME or not CANDIDATE_NUMBER:
        print("Error: Environment variables BUCKET_NAME or CANDIDATE_NUMBER are missing.")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Environment variables BUCKET_NAME or CANDIDATE_NUMBER are missing"})
        }
    
    print(f"Environment - BUCKET_NAME: {BUCKET_NAME}, CANDIDATE_NUMBER: {CANDIDATE_NUMBER}")

    # Parse the request body for the prompt
    try:
        body = json.loads(event["body"])
        prompt = body.get("prompt", "")
    except json.JSONDecodeError:
        print("Error: Invalid JSON format in request body.")
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Invalid JSON format in request body"})
        }

    if not prompt:
        print("Error: Prompt not provided.")
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Prompt not provided"})
        }

    # Generate a random seed and S3 path
    seed = random.randint(0, 2147483647)
    s3_image_path = f"{CANDIDATE_NUMBER}/images/titan_{seed}.png"
    print(f"Generated S3 image path: {s3_image_path}")

    # Create the request payload for image generation
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
    try:
        print("Invoking Bedrock model with payload:", native_request)
        response = bedrock_client.invoke_model(
            modelId=MODEL_ID,
            body=json.dumps(native_request)
        )
        model_response = json.loads(response["body"].read())
        base64_image_data = model_response["images"][0]
        image_data = base64.b64decode(base64_image_data)
        print("Image generated successfully.")
    except Exception as e:
        print("Error during Bedrock model invocation:", e)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": f"Error invoking Bedrock model: {str(e)}"})
        }

    # Upload the generated image to S3
    try:
        print(f"Uploading image to S3 bucket: {BUCKET_NAME}, path: {s3_image_path}")
        s3_client.put_object(Bucket=BUCKET_NAME, Key=s3_image_path, Body=image_data)
        print("Image uploaded to S3 successfully.")
    except Exception as e:
        print("Error during S3 upload:", e)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": f"Error uploading to S3: {str(e)}"})
        }

    # Return success response with S3 path
    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Image generated and uploaded", "s3_path": s3_image_path})
    }


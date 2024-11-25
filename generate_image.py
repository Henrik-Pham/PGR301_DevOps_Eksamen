import base64
import boto3
import json
import random

bedrock_client = boto3.client("bedrock-runtime", region_name="us-west-1")
s3_client = boto3.client("s3")

model_id = "amazon.titan-image-generator-v1"
bucket_name = "pgr301-couch-explorers"

prompt = "Investors, with circus hats, giving money to developers with large smiles"

seed = random.randint(0, 2147483647)
s3_image_path = f"generated_images/titan_{seed}.png"

native_request = {
    "taskType": "TEXT_IMAGE",
    "textToImageParams": {"text": prompt},
    "imageGenerationConfig": {
        "numberOfImages": 1,
        "quality": "standard",
        "cfgScale": 8.0,
        "height": 1024,
        "width": 1024,
        "seed": seed,
    }
}

response = bedrock_client.invoke_model(modelId=model_id, body=json.dumps(native_request))
model_response = json.loads(response["body"].read())

base64_image_data = model_response["images"][0]
image_data = base64.b64decode(base64_image_data)

s3_client.put_object(Bucket=bucket_name, Key=s3_image_path, Body=image_data)
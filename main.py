import time
import boto3
import json

kinesis_client = boto3.client('kinesis', region_name='eu-west-1')

for x in range(1000):
    time.sleep(5)
    print("Hello World!")
    payload = {
                "message": "hello world",
                "name" : "Lars"
              }

    kinesis_client.put_record(
                        StreamName='terraform-kinesis-test',
                        Data=json.dumps(payload),
                        PartitionKey='thing_id')

    print(kinesis_client.describe_stream(StreamName='terraform-kinesis-test'))
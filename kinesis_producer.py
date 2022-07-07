""" Simple Kinesis Publisher """

import json
import datetime
from typing import Iterable
import boto3
import uuid

class KinesisProducer():
    """ Simple Kinesis Publisher """

    def __init__(self, stream_name: str):
        self.stream_name = stream_name
        self.client = boto3.client('kinesis')


    def publish(self, partition_key: str, payload: str):
        """ Publish a payload to kinesis """
      
        result = self.client.put_record(
            StreamName=self.stream_name,
            Data=payload,
            PartitionKey=str(partition_key))
        print(result)

    def publish_many(self, records: Iterable):
        """ Publish multiple records """

        kinesis_records = []
        for thing in records:
            for key, value in thing.items():
                row = { "PartitionKey": str(key), "Data": json.dumps(value) }
                kinesis_records.append(row)
        result = self.client.put_records(
            StreamName=self.stream_name,
            Records=kinesis_records
        )
        print(result)



if __name__ == '__main__':

    now = datetime.datetime.now().isoformat()
   
    users = [
        """
        {
    "header": {
        "eventId": "b8240643-8f22-4cb8-8640-fe17d43f30ae",
        "tenantId": "80e9f2ba-b31e-4226-a1b4-72c8322d69b6",
        "eventTimestamp": "2022-06-22T13:30:00.323Z",
        "eventType": "FoobarEvent"
    },
    "body": {
       "oldData": {
            "Patient": {
                "Name": "Bob"
            }
       },
       "newData": {
            "Patient": {
                "Name": "Larry"
            }
       }
    }
}   
        """
    ]
    
   
    producer = KinesisProducer("ingest-test-stream")
    produced = 0
    for user in users:
        user_json = json.loads(user)
        while (produced < 500000):
            rows = []
            for x in range(500):
                user_json["header"]["eventId"] = str(uuid.uuid4())
                rows.append({str(user_json["header"]["eventId"]): user_json})
        
            producer.publish_many(rows)
            produced += 500

""" Ingest Lambda Function """

from typing import Dict, Any
import json
import base64
import copy
from datetime import datetime
from dateutil import tz


#todo: have to load this from somewhere
def get_tenant_timezone(tenant_id: str):
    """ Get the timezone for a tenant timezone conversion - stub for real data """
    zones = {
        "80e9f2ba-b31e-4226-a1b4-72c8322d69b6": "US/Pacific"
    }
    return zones[tenant_id]


def transform_data(data: Any): # crap but thats what json.loads returns
    """ Add a local date for input UTC dates """

    date_format = '%Y-%m-%dT%H:%M:%S.%f%z'
    local = copy.deepcopy(data)

    local['header']['eventTimestampUTC'] = local['header']['eventTimestamp']
    event_timestamp = datetime.strptime(local['header']['eventTimestamp'], date_format)
    event_timestamp =  event_timestamp.replace(tzinfo=tz.gettz("UTC"))

    local_tz = tz.gettz(get_tenant_timezone(local['header']['tenantId']))
    event_timestamp_local = event_timestamp.astimezone(local_tz)
    local['header']['eventTimestamp'] = event_timestamp_local.strftime(date_format)
    return local


def lambda_handler(event: Any, _) -> Dict[str, list]:
    """ AWS Lambda handler"""

    output = []

    for record in event['records']:
        data = base64.b64decode(record['data'])
        json_data = json.loads(data)

        # transform data
        new_data = transform_data(json_data)

        # create output record
        output_record = {
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': base64.b64encode(json.dumps(new_data,
            separators=(',', ':')).encode('utf-8') + b'\n').decode('utf-8')
        }
        output.append(output_record)
    return { 'records': output }

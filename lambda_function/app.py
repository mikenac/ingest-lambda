""" Ingest Lambda Function """

from typing import Dict, Any
import json
import base64
import copy
from datetime import datetime
import re
from dateutil import tz
import morph



def get_key_tail(input_str):
    """ Get the last part of the key """
    last_dot = input_str.rfind(".")
    if last_dot != -1:
        return input_str[last_dot + 1:]
    return input

def get_key_parent(input_str):
    """ Get the parent to the last part of the key """
    last_dot = input_str.rfind(".")
    if last_dot != -1:
        return input_str[:last_dot]
    return input

#todo: have to load this from somewhere
def get_tenant_timezone(tenant_id: str):
    """ Get the timezone for a tenant timezone conversion - stub for real data """
    zones = {
        "80e9f2ba-b31e-4226-a1b4-72c8322d69b6": "US/Pacific"
    }
    return zones[tenant_id]

def utc_to_local(input_date, time_zone, date_format= '%Y-%m-%dT%H:%M:%S.%f%z'):
    """ Convert a utc string date into a local string date"""
    input_as_timestamp = datetime.strptime(input_date, date_format).replace(tzinfo=tz.gettz("UTC"))
    return input_as_timestamp.astimezone(time_zone).strftime(date_format)

def transform_data(data: Any): # crap but thats what json.loads returns
    """ Add a local date for input UTC dates """

    search_pattern = "(date|datetime|timestamp)"
    flat = morph.flatten(data)
    local_flat = copy.deepcopy(flat)
    local_tz = tz.gettz(get_tenant_timezone(flat["header.tenantId"])) 
    for k, v in flat.items():
        key = get_key_tail(k)
        res = re.search(search_pattern, key, re.IGNORECASE)
        if (res):
            parent = get_key_parent(k)
            local_flat[parent + "." + key + "UTC"] = v
            local_flat[k] = utc_to_local(v, local_tz)
    return morph.unflatten(local_flat)


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

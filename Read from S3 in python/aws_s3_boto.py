#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2154
# ------------------------------------------------------------------------------
#  PURPOSE:       LIST Contents of S3 bucket 
# ------------------------------------------------------------------------------
#  PREREQS: a) 
#           b) 
#           c) 
#           d)
# ------------------------------------------------------------------------------
#  EXECUTE: python3 aws_s3_boto.py
# ------------------------------------------------------------------------------
#     TODO: 1) 
#           2) 
#           3) 
# ------------------------------------------------------------------------------
#   AUTHOR: Ramya Murthy
# ------------------------------------------------------------------------------
#  CREATED: 2021/10/00
# ------------------------------------------------------------------------------
#set -x


###-----------------------------------------------------------------------------
### VARIABLES
###-----------------------------------------------------------------------------
#  




import json
import sys
import boto3
import io



session = boto3.session.Session()
print("session = \n",session)
current_region = session.region_name
print(current_region)

access_key=session.get_credentials().access_key
print(access_key)
secret_access_key=session.get_credentials().secret_key
print(secret_access_key)
session_token=session.get_credentials().session_token
print(session_token)

client = boto3.client(
    's3',
    aws_access_key_id = 'xxxxxxxxxxxxxxxxxxxx',
    aws_secret_access_key = 'xxxxxxxxxxxxxxxxxxxx',
    region_name = current_region 
)

resource = boto3.resource(
    's3',
    aws_access_key_id = 'xxxxxxxxxxxxxxxxxxxx',
    aws_secret_access_key = 'xxxxxxxxxxxxxxxxxxxx',
    region_name = current_region 

)



array=[]
response = client.list_objects_v2(Bucket='test-data-rfss')
print ("response = ", response)
keycount=response.get('KeyCount')
print(keycount)
for content in response.get('Contents', []):
    print(content['Key'])
    array.append(content['Key'])
'''
#print(array)
for i in array:
  print("************************", i)
  print(type(i))
  obj = client.get_object(
      Bucket = 'test-data-rfss',
      Key = i
  )
#  df=pandas.read_excel(io.BytesIO(obj['Body'].read()))
#  print(df)
'''

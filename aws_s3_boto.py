import json
import pandas
import sys
import boto3
import io
import openpyxl


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
    aws_access_key_id = 'AKIASEUVLPCLWPJIGWNI',
    aws_secret_access_key = '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',
    region_name = current_region 
)

resource = boto3.resource(
    's3',
    aws_access_key_id = 'AKIASEUVLPCLWPJIGWNI',
    aws_secret_access_key = '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',
    region_name = current_region 
    #region_name = 'us-east-2'
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

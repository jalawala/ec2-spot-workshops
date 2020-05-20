from flask import Flask, render_template
from flask.ext.cors import CORS, cross_origin
import os
import requests
import json
import time
import sys
from ec2_metadata import ec2_metadata
import boto3
 



    
app = Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

 
@app.route('/')
@cross_origin()
def index():
  
    response = ""
    response +="<head> <title>Spot Game Day</title> </head>"
    response += "<h2>I am a Simple Containerized Web App Running with below Attributes </h2> <hr/>"

    try:
      instanceId = ec2_metadata.instance_id
      response += "<li>My instance_id = {}</li>".format(instanceId)
      lifecycle = getInstanceLifecycle(instanceId)      
      response += "<li>My Instance lifecycle = {}</li>".format(lifecycle)      
      response += "<li>My instance_type = {}</li>".format(ec2_metadata.instance_type)      
      response += "<li>My private_ipv4 = {}</li>".format(ec2_metadata.private_ipv4)  
      response += "<li>My public_ipv4 = {}</li>".format(ec2_metadata.public_ipv4)       
      response += "<li>My availability_zone = {}</li>".format(ec2_metadata.availability_zone)      
      response += "<li>My Region = {}</li>".format(ec2_metadata.region)      
      response += "<li>My ami_launch_index = {}</li>".format(ec2_metadata.ami_launch_index)      
 
      networks = ec2_metadata.network_interfaces
      for nw in networks:
        response += "<li>My subnet_id = {}</li>".format(ec2_metadata.network_interfaces[nw].subnet_id)
        response += "<li>My vpc_id = {}</li>".format(ec2_metadata.network_interfaces[nw].vpc_id)


    except Exception as inst:
      response += "<li>Oops !!! Failed to access my instance  metadata with error = {}</li>".format(inst)

    return response

def getInstanceLifecycle(instanceId):
  ec2client = boto3.client('ec2', region_name=ec2_metadata.region)
  describeInstance = ec2client.describe_instances(InstanceIds=[instanceId])
  instanceData=describeInstance['Reservations'][0]['Instances'][0]
  if 'InstanceLifecycle' in instanceData.keys():
    return instanceData['InstanceLifecycle']
  else:
    return "Ondemand"


if __name__ == '__main__':
    print("Starting A Simple Web Service ...")
    app.run(port=80,host='0.0.0.0')

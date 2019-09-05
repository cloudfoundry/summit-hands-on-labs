from flask import Flask, render_template
import requests
import json
import os

#backend_url = 'http://0.0.0.0:8080'
backend_url = os.getenv('BACKEND_URL')

# helper, who gets URL content as html

def get_request (url):

   r = requests.get(url)
   tree = html.fromstring(r.text)

   return tree

app = Flask(__name__)

@app.route("/")
def greeting():

    gcp = requests.get(backend_url + '/gcp').text
    gcp_json = json.loads(gcp)
    aws = requests.get(backend_url + '/aws_eu').text
    aws_json = json.loads(aws)
    backend = requests.get(backend_url + '/status').text
    backend_json = json.loads(backend)
     
    return render_template('index.html', gcp_date=gcp_json['date'], gcp_status=gcp_json['state'], aws_status=aws_json['status'], backend_id=backend_json['instance_id'], backend_guid=backend_json['instance_guid'], backend_port=backend_json['instance_port']) 

if __name__ == "__main__":
    app.run(host = '0.0.0.0', port = os.getenv('PORT') ,debug = True)

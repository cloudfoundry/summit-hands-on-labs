from flask import Flask, request
import os
# set the project root directory as the static folder, you can set others.
app = Flask(__name__, static_url_path='')

@app.route('/')
def root():
    return app.send_static_file('index.html')

if __name__ == "__main__":
    app.run(host = '0.0.0.0', port = os.getenv('PORT'), debug = True)

var http = require('http');

var handleRequest = function(request, response) {
  try {
    var creds = JSON.parse(process.env.VCAP_SERVICES).otherservice[0].credentials;
    response.writeHead(200);
    response.end('USERNAME: ' + creds.username + "\nPASSWORD: " + creds.password);
  } catch(err) {
    response.writeHead(418);
    response.end("I'm a teapot and I'm confused.");
  }
};

http.createServer(handleRequest).listen(process.env.PORT);

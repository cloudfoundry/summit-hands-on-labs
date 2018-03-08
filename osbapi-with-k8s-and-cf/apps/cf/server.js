var http = require('http');

var handleRequest = function(request, response) {
  var creds = JSON.parse(process.env.VCAP_SERVICES).myservice[0].credentials;
  response.writeHead(200);
  response.end('USERNAME: ' + creds.username + "\nPASSWORD: " + creds.password);
};

http.createServer(handleRequest).listen(process.env.PORT);

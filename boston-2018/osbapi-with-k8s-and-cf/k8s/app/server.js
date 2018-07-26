var http = require('http');

var handleRequest = function(request, response) {
  response.writeHead(200);
  response.end('USERNAME: ' + process.env.BINDING_USERNAME + "\nPASSWORD: " + process.env.BINDING_PASSWORD + "\n");
};

http.createServer(handleRequest).listen(8080);

var http = require('http');

var handleRequest = function(request, response) {
  var parsed_services = JSON.parse(process.env.VCAP_SERVICES)
  var message = '';
  if (Object.keys(parsed_services).length > 0) {
    service_name = Object.keys(parsed_services)[0];
    var creds = parsed_services[service_name][0].credentials;
    message = "Credentials available: username is '" + creds.username + "' and password is '" + creds.password+ "'\n";
  } else {
    message = 'No service instances are bound to this app.\n';
  }

  response.writeHead(200);
  response.end(message);
};

http.createServer(handleRequest).listen(process.env.PORT);

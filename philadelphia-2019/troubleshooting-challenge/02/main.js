var http = require('http');
var port = parseInt(process.env.PORT,10);

var server = http.createServer(
  function (req, res) {
    res.writeHead(200, { 'Content-Type': 'text/plain'});
    res.end("Hello Cloud Foundry Summit @ Bazel!");
  }
);

server.listen(port, '0.0.0.0');
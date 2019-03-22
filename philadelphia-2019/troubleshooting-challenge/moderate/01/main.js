var http = require('http');
var port = parseInt(process.env.PORT,10);

var server = http.createServer(
  function (req, res) {
    res.writeHead(200, { 'Content-Type': 'text/html'});
    res.write("<head><style type='text/css'> body {font-size: 56px;font-weight: bold; background-color: #f49e42; text-align: center;}</style></head>");
    res.end("<body>CONGRATULATIONS<br>you just completed moderate task #01</body>");
  }
);

server.listen(port, '0.0.0.0');
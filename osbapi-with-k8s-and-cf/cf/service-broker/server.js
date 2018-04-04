var fs = require('fs');
var express = require('express');
var uuid = require('uuid/v4');

var app = express();

app.get('/v2/catalog', function(req, res) {
  res.send(fs.readFileSync("catalog.json"));
  res.status(200);
})

// Provision a service instance. In our example, this is a no-op.
app.put('/v2/service_instances/[^/]+(\\?.*)?$', function(req, res) {
  res.status(201);
  res.send('{}');
})

// Delete a service instance. In our example, this is a no-op.
app.delete('/v2/service_instances/[^/]+(\\?.*)?$', function(req, res) {
  res.status(200);
  res.send('{}');
})

// Create a service binding
app.put('/v2/service_instances/[^/]+/service_bindings/[^/]+(\\?.*)?$', function(req, res) {
  res.status(201);
  res.send('{"credentials" : {"username" : "admin", "password" : "p4ssw0rd"}}');
})

// Delete a service binding
app.delete('/v2/service_instances/[^/]+/service_bindings/[^/]+(\\?.*)?$', function(req, res) {
  res.status(200);
  res.send('{}');
})

// Listen on the port given to us by Cloud Foundry
app.listen(process.env.PORT);

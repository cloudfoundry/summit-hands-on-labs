var fs = require('fs');
var express = require('express');
var uuid = require('uuid/v4');

var app = express();

app.get('/v2/catalog', function(req, res) {
  console.log("catalog called")
  res.status(200);
  var catalog = JSON.parse(fs.readFileSync("catalog.json"));

  // Generate random service and plan IDs, since they must be globally unique within the platform.
  catalog.services.forEach(function (s) {
    s.id = uuid();
    s.plans.forEach(function (p) {
      p.id = uuid();
    });
  });

  res.send(JSON.stringify(catalog));
})

// NO-OP provision
app.put('/v2/service_instances/[^/]+(\\?.*)?$', function(req, res) {
  console.log("creeate instance called")
  res.status(201);
  res.send('{}');
})

app.delete('/v2/service_instances/[^/]+(\\?.*)?$', function(req, res) {
  console.log("delete instance called")
  res.status(200);
  res.send('{}');
})

// Binding
app.put('/v2/service_instances/[^/]+/service_bindings/[^/]+(\\?.*)?$', function(req, res) {
  console.log("create binding called")
  res.status(201);
  res.send('{"credentials" : {"username" : "admin", "password" : "p4ssw0rd"}}');
})

app.delete('/v2/service_instances/[^/]+/service_bindings/[^/]+(\\?.*)?$', function(req, res) {
  console.log("delete binding called")
  res.status(200);
  res.send('{}');
})


app.listen(process.env.PORT);

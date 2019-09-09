let express = require("express");
let app = express();
let port = parseInt(process.env.PORT,10);
let address = process.env.CF_INSTANCE_IP

app.use(express.static('static'));

if (!port) {
  console.log("PORT is not set up.")
  return 23;
}
console.log("Server is liten on address " + address + " and port " + port)
let server = app.listen(port, address);


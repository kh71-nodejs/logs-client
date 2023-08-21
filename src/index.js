const pmx = require('pmx');
const conf = pmx.getConf();

const socket = require("./services/socket")(conf);
let connection = false;
socket.on("connect_error", function (err) {
  connection = false;
});

socket.on("reconnect", (socket) => {
  connection = true;
});

const db = require("./models/index");
const PM2Model = require('./models/tbl_pm2');
const _PM2Model = new PM2Model(db);
_PM2Model.socket = socket;

setInterval(function () {
  if (connection)
    _PM2Model.resubmit();
}, 2000);


function emit(data, key = "pm2") {
  try {
    const json = JSON.parse(data.toString());
    if (json.app_name != "logs-client") {
      if (connection) {
        socket.emit(key, json);
      } else {
        switch (key) {
          case "pm2":
            console.log(json.app_name);
            _PM2Model.create(json);
            break;
          default:
            break;
        }
      }
    }
  } catch (error) {
    // console.log("error", data.toString())
  }
}

// Service Start
require("./services/pm2")(emit);
require("./services/monitoring")(emit);

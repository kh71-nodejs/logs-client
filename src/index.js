const pmx = require('pmx');
const conf = pmx.getConf();

const socket = require("./services/socket")(conf);

function emit(data) {
  try {
    const json = JSON.parse(data);
    if (json.app_name != "logs-client") {
      socket.emit("event", JSON.stringify(json));
    }
  } catch (error) {

  }
}

require("./services/pm2")(emit);

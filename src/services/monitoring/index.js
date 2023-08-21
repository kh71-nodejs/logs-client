const pmx = require('pmx');
const conf = pmx.getConf();
const { spawn } = require("node:child_process");
const { resolve } = require("path");

function monit(emit) {
  this.emit = emit;
  setInterval(function () {
    loop();
  }, 1000 * parseInt(conf?.refreshMonit || 60));
}

function loop() {
  const execProcess = spawn("bash", [resolve(process.cwd(), `src/services/monitoring/agent.sh`)]);
  execProcess.stdout.on("data", (data) => {
    this.emit(data.toString().replace(/'/g, '"'), "monit");
    // console.log(`spawn stdout: ${data}`);
  });
}

module.exports = monit;

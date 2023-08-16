const { spawn } = require('node:child_process');
function spawnCommnad(ee, command, args) {
  const execProcess = spawn(command, args);
  execProcess.on("spawn", () => {
    console.log("Client Start");
    // ee.emit('event', "Client Start");
  });
  execProcess.stdout.on("data", (data) => {
    ee.emit('event', data);
    // console.log(`spawn stdout: ${data}`);
  });
  execProcess.stderr.on("data", (data) => {
    ee.emit('event', data);
    // console.log(`spawn on error ${data}`);
  });
  execProcess.on("exit", (code, signal) => {
    ee.emit('event', signal);
    // console.log(`spawn on exit code: ${code} signal: ${signal}`);
  });
  execProcess.on("close", (code, args) => {
    ee.emit('event', args);
    // console.log(`spawn on close code: ${code} args: ${args}`);
  });
}

module.exports = spawnCommnad;
// spawnCommnad("pm2", ["logs", "--json"]);

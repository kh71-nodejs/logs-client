const { spawn } = require('node:child_process');

const pm2 = function (socket) {
  const execProcess = spawn("pm2", ["logs", "--json"]);
  execProcess.on("spawn", () => {
    // console.log("Client Start");
    // emit("Client Start");
  });
  execProcess.stdout.on("data", (data) => {
    socket(data);
    // console.log(`spawn stdout: ${data}`);
  });
  execProcess.stderr.on("data", (data) => {
    socket(data);
    // console.log(`spawn on error ${data}`);
  });
  execProcess.on("exit", (code, signal) => {
    socket(signal);
    // console.log(`spawn on exit code: ${code} signal: ${signal}`);
  });
  execProcess.on("close", (code, args) => {
    socket(args);
    // console.log(`spawn on close code: ${code} args: ${args}`);
  });
}

module.exports = pm2;

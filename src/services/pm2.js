const { spawn } = require('node:child_process');

const pm2 = function (emit) {
  const execProcess = spawn("pm2", ["logs", "--json"]);
  execProcess.on("spawn", () => {
    // console.log("Client Start");
    // emit("Client Start");
  });
  execProcess.stdout.on("data", (data) => {
    emit(data);
    // console.log(`spawn stdout: ${data}`);
  });
  execProcess.stderr.on("data", (data) => {
    emit(data);
    // console.log(`spawn on error ${data}`);
  });
  execProcess.on("exit", (code, signal) => {
    emit(signal);
    // console.log(`spawn on exit code: ${code} signal: ${signal}`);
  });
  execProcess.on("close", (code, args) => {
    emit(args);
    // console.log(`spawn on close code: ${code} args: ${args}`);
  });
}

module.exports = pm2;

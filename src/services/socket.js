const socketClient = require("socket.io-client");

const Socket = (conf) => {
  const port = conf?.SocketPort ? ":" + conf?.SocketPort : "";
  const SS = conf?.SocketServer || "localhost";
  const PROTOCOL = conf?.SocketProtocol || "ws";

  const socket = socketClient(`${PROTOCOL}://${SS}${port}`, {
    transports: ["websocket"],
    auth: {
      token: conf?.SecretToken || "token",
      from: conf?.ServerName || "express",
    },
  });

  socket.on("connect_error", function (err) {
    console.log(err.message);
  });

  return socket;
}

// const util = require("util");
// const EventEmitter = require("events").EventEmitter;

// socket.on('event', function (text) {
//   if (text.toString()?.trim() != "")
//     socket.emit("event", text.toString()?.trim());
// });

module.exports = Socket;

const socketClient = require("socket.io-client");
const EventEmitter = require("events");

const ee = new EventEmitter();

const port = process.env.SocketPort || "8080";
const SS = process.env.SocketServer || "localhost";
const PROTOCOL = process.env.SocketProtocol || "ws";
const socket = socketClient(process.env?.SocketDomain || `${PROTOCOL}://${SS}:${port}`, {
  transports: ["websocket"],
  auth: {
    token: process.env.SecretToken || "token",
    from: process.env.ServerName || "express",
  },
});
socket.on("connection", function (socket) {
  socket.on("chat message", function (msg) {
  });
});

ee.on('event', function (text) {
  if (text.toString()?.trim() != "")
    socket.emit("event", text.toString()?.trim());
});

module.exports = ee;

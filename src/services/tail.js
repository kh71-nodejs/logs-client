const Tail = require('tail').Tail;
const EventEmitter = require("events");

const ee = new EventEmitter();

function tailFile(ee, path) {
  console.log(path);
  const tail = new Tail(path);

  tail.on("line", function (data) {
    ee.emit('event', data);
    console.log(data);
  });

  tail.on("error", function (error) {
    console.log('ERROR: ', error);
  });
}

module.exports = tailFile;

const Tail = require('tail').Tail;

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

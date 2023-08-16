require("dotenv/config");
const ee = require("./services/socket");

const spawnCommnad = require("./services/pm2");
const tail = require("./services/tail");

spawnCommnad(ee, "pm2", ["logs", "--json"]);

if (process.env?.FileLogs) {
  try {
    const FileLogs = process.env?.FileLogs?.split("|") || [];
    FileLogs.forEach(pathFile => {
      try {
        tail(ee, pathFile);
      } catch (error) {

      }
    });
  } catch (error) {

  }
}

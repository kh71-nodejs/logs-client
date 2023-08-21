
function PM2Model(db) {
  db.prepare(`CREATE TABLE IF NOT EXISTS pm2 (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    message TEXT,
    timestamp TEXT,
    type TEXT,
    process_id INTEGER,
    status TEXT,
    app_name TEXT,
    server TEXT,
    emit INTEGER DEFAULT 0
    )`).run().finalize();
  this.db = db;
}

PM2Model.prototype.create = function (json) {
  if (json.app_name) {
    return this.db.run(
      `INSERT INTO pm2
    (
      message,
      timestamp,
      type,
      process_id,
      status,
      app_name
    )
      VALUES (?, ?, ?, ?, ?, ?)`,
      [
        json?.message || "",
        json?.timestamp || "",
        json?.type || "",
        json?.process_id,
        json?.status || "",
        json?.app_name || ""
      ],
      (err) => {
        console.log(err);
      }
    );
  }
}

PM2Model.prototype.resubmit = function () {
  this.db.get("SELECT * FROM pm2 WHERE emit=0", [], (err, row) => {
    if (row)
      this.db.run(`UPDATE pm2 SET emit=1 WHERE id=${row.id}`, [], (err) => {
        if (!err)
          this.socket.emit("pm2", row);
      });
  });
}


module.exports = PM2Model;

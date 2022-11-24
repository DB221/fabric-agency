const oracledb = require("oracledb");

let dbConnection;

module.exports = {
  connectToDatabase: async function (username, password) {
    dbConnection = await oracledb.getConnection({
      user: username,
      password: password,
      connectionString: "localhost:1521/xe",
    });
  },
  getDb: function () {
    if (!dbConnection) {
      throw { message: "Cannot connect to database." };
    }
    return dbConnection;
  },
};

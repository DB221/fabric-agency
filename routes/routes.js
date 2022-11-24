const express = require("express");
const router = express.Router();
const dbo = require("../db/config");
const { auth } = require("../helper/auth");

// const db = dbo.getDb();
let session;

router.get("/", auth, async (req, res) => {
  res.send("hehe");
});

// get all suppliers
router.get("/suppliers", async (req, res) => {});

// create a new supplier
router.post("/supplier", async (req, res) => {
  const query = "INSERT ";
  const result = await dbo.getDb().execute(query);
  res.send(result);
});

// update a supplier
router.post("/supplier/:id", async (req, res) => {});

// get all categories
router.get("/categories", async (req, res) => {});

/* GET home page. */
router.get("/employees", async (req, res, next) => {
  const result = await dbo.getDb().execute("select * from EMPLOYEE");
  res.send(result);
});

// login
router.post("/login", async (req, res) => {
  const username = req.body.username;
  const password = req.body.password;

  try {
    await dbo.connectToDatabase(username, password);
  } catch (e) {
    console.log({ e });
    return res.status(400).send("Invalid username or password");
  }
  session = req.session;
  session.userid = username;
  console.log({ session });
  res.send("OK");
});

// logout
router.get("/logout", (req, res) => {
  req.session.destroy();
  res.redirect("/");
});

module.exports = router;

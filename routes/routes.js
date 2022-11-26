const express = require("express");
const router = express.Router();
const dbo = require("../db/config");
const { auth } = require("../helper/auth");

// const db = dbo.getDb();
let session;

router.get("/", auth, async (req, res) => {
  res.send("hehe");
});

// get all suppliers (for suppliers view)
router.get("/suppliers", auth, async (req, res) => {
  const suppliers = await dbo.getDb().execute("SELECT * FROM SUPPLIER");
  res.send(suppliers);
});

// 2. Add information for a new supplier
router.post("/supplier", auth, async (req, res) => {
  const query = "INSERT ";
  const result = await dbo.getDb().execute(query);
  res.send(result);
});

// 3. Get details of all categories which are provided by a supplier
router.get("/supplier/:sCode/categories", auth, async (req, res) => {
  const sCode = req.params.sCode;

  const query = `SELECT * FROM CATEGORY WHERE S_CODE = '${sCode}'`;
  const result = await dbo.getDb().execute(query);

  res.send(result);
});

// get all customers (for customer view)
router.get("/customers", auth, async (req, res) => {
  const customers = await dbo.getDb().execute("SELECT * FROM CUSTOMER");
  res.send(customers);
});

// 4. Report that provides full information about the order for each category of a customer
router.get("/report/customer", async (req, res) => {
  const query = "";
  const result = await dbo.getDb().execute(query);
  res.send(result);
});

// get all categories (for categories view)
router.get("/categories", auth, async (req, res) => {
  const categories = await dbo.getDb().execute("SELECT * FROM CATEGORY");
  res.send(categories);
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
  session.userId = username;
  console.log({ session });
  res.send("OK");
});

// logout
router.get("/logout", (req, res) => {
  req.session.destroy();
  res.redirect("/");
});

module.exports = router;

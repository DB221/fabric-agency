const express = require("express");
const router = express.Router();
const dbo = require("../db/config");
const { auth } = require("../helper/auth");

// const db = dbo.getDb();
let session;

router.get("/", async (req, res) => {
  res.redirect("/suppliers");
});

// get all suppliers (for suppliers view)
router.get("/suppliers", async (req, res) => {
  const suppliers = await dbo.getDb().execute("SELECT * FROM SUPPLIER");
  res.render("suppliers", { suppliers: suppliers.rows });
});

// 2. Add information for a new supplier
router.post("/supplier", async (req, res) => {
  const query = "INSERT ";
  const result = await dbo.getDb().execute(query);
  res.send(result);
});

// 3. Get details of all categories which are provided by a supplier
router.get("/supplier/:sCode/categories", async (req, res) => {
  const sCode = req.params.sCode;

  const query = `SELECT * FROM CATEGORY WHERE S_CODE = '${sCode}'`;
  const categories = await dbo.getDb().execute(query);

  res.render("supplier-categories", { sCode, categories: categories.rows });
});

// get all customers (for customer view)
router.get("/customers", async (req, res) => {
  const customers = await dbo.getDb().execute("SELECT * FROM CUSTOMER");
  res.render("customers", { customers: customers.rows });
});

// 4. Report that provides full information about the order for each category of a customer
router.get("/report/customer", async (req, res) => {
  const query = "";
  const result = await dbo.getDb().execute(query);
  res.send(result);
});

// get all categories (for categories view)
router.get("/categories", async (req, res) => {
  const categories = await dbo.getDb().execute("SELECT * FROM CATEGORY");
  res.render("categories", { categories: categories.rows });
});

// login
router.get("/login", async (req, res) => {
  res.render("login");
});

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

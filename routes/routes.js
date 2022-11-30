const express = require("express");
const router = express.Router();
const dbo = require("../db/config");
const { auth } = require("../helper/auth");

// const db = dbo.getDb();
let session;

router.get("/", async (req, res) => {
  res.redirect("/suppliers");
});

///////////////////////////////////////////////////////////////////// SUPPLIERS /////////////////////////////////////////////////////////////////////
// get all suppliers (for suppliers view)
router.get("/suppliers", async (req, res) => {
  const suppliers = await dbo.getDb().execute("SELECT * FROM SUPPLIER");

  for (let supplier of suppliers.rows) {
    const phoneNum = await dbo
      .getDb()
      .execute(
        `SELECT * FROM SUP_PHONE_NUMBERS WHERE S_Code = '${supplier[0]}'`
      );

    let phoneNumsField = "";
    for (let i = 0; i < phoneNum.rows.length; ++i) {
      phoneNumsField += phoneNum.rows[i][1];
      if (i != phoneNum.rows.length - 1) {
        phoneNumsField += ", ";
      }
    }

    supplier.push(phoneNumsField);
  }

  // pagination data
  const limit = 12;
  let page = parseInt(req.query.page);

  if (!page || page < 0) {
    page = 1;
  }

  const startIndex = (page - 1) * limit;
  const endIndex = page * limit;
  const pagin = {};

  if (startIndex > 0) {
    pagin.prev = `/suppliers?page=${page - 1}`;
  }

  if (endIndex < suppliers.rows.length) {
    pagin.next = `/suppliers?page=${page + 1}`;
  }
  pagin.suppliers = suppliers.rows.slice(startIndex, endIndex);
  pagin.limit = limit;
  let pageSize = Math.ceil(suppliers.rows.length / limit);
  pagin.pages = [];
  for (let i = 0; i < pageSize; ++i) {
    pagin.pages.push(i + 1);
  }

  const successMessage = req.flash("successMessage")[0];

  res.render("suppliers", {
    pagin: pagin,
    successMessage,
  });
  // res.send(pagin);
});

// 2. Add information for a new supplier
router.get("/supplier-insert", async (req, res) => {
  const dangerMessage = req.flash("dangerMessage")[0];
  res.render("supplier-insert", { dangerMessage });
});

router.post("/supplier", async (req, res) => {
  // sup_code, sname, address, bank_account, tax_code, partner_staff_code
  const name = req.body.name;
  const address = req.body.address;
  const bankAccount = req.body.bank_account;
  const taxCode = req.body.tax_code;
  const partnerStaffCode = req.body.partner_staff_code;
  const phoneNumber = req.body.phone_number;

  const query = `INSERT INTO SUPPLIER VALUES ('', '${name}', '${address}', '${bankAccount}', '${taxCode}', '${partnerStaffCode}')`;
  try {
    await dbo.getDb().execute(query);
    if (phoneNumber) {
      const queryPhone = `SELECT * FROM SUPPLIER WHERE 
      name ='${name}' AND address = '${address}' AND Bank_Account = '${bankAccount}' AND Tax_Code = '${taxCode}' AND Partner_Staff_Code = '${partnerStaffCode}'`;
      const sup = await dbo.getDb().execute(queryPhone);

      const newSCode = sup.rows[0][0];
      const queryInsertPhone = `INSERT INTO SUP_PHONE_NUMBERS VALUES ('${newSCode}', '${phoneNumber}')`;
      await dbo.getDb().execute(queryInsertPhone);
    }
  } catch (e) {
    req.flash("dangerMessage", `${e.message}`);
    return res.redirect("/supplier-insert");
  }
  req.flash("successMessage", "Success! New supplier inserted.");
  res.redirect("/suppliers");
});

// 3. Get details of all categories which are provided by a supplier
router.get("/supplier/:sCode/categories", async (req, res) => {
  const sCode = req.params.sCode;

  const query = `SELECT * FROM CATEGORY WHERE S_CODE = '${sCode}'`;
  const categories = await dbo.getDb().execute(query);

  // pagination data
  const limit = 12;
  let page = parseInt(req.query.page);

  if (!page || page < 0) {
    page = 1;
  }

  const startIndex = (page - 1) * limit;
  const endIndex = page * limit;
  const pagin = {};

  if (startIndex > 0) {
    pagin.prev = `/supplier/${sCode}/categories?page=${page - 1}`;
  }

  if (endIndex < categories.rows.length) {
    pagin.next = `/supplier/${sCode}/categories?page=${page + 1}`;
  }
  pagin.categories = categories.rows.slice(startIndex, endIndex);
  pagin.limit = limit;
  let pageSize = Math.ceil(categories.rows.length / limit);
  pagin.pages = [];
  for (let i = 0; i < pageSize; ++i) {
    pagin.pages.push({ pageNum: i + 1, sCode });
  }

  res.render("supplier-details", { sCode, pagin });
});

router.get("/supplier/:sCode/phone-nums", async (req, res) => {
  const sCode = req.params.sCode;

  const query = `SELECT * FROM SUP_PHONE_NUMBERS WHERE S_CODE = '${sCode}'`;
  const phoneNums = await dbo.getDb().execute(query);

  // pagination data
  const limit = 12;
  let page = parseInt(req.query.page);

  if (!page || page < 0) {
    page = 1;
  }

  const startIndex = (page - 1) * limit;
  const endIndex = page * limit;
  const pagin = {};

  if (startIndex > 0) {
    pagin.prev = `/phone-nums?page=${page - 1}`;
  }

  if (endIndex < phoneNums.rows.length) {
    pagin.next = `/phone-nums?page=${page + 1}`;
  }
  pagin.phoneNums = phoneNums.rows.slice(startIndex, endIndex);
  pagin.limit = limit;
  let pageSize = Math.ceil(phoneNums.rows.length / limit);
  pagin.pages = [];
  for (let i = 0; i < pageSize; ++i) {
    pagin.pages.push({ pageNum: i + 1, sCode });
  }

  res.render("supplier-details", { sCode, pagin });
});

// search
router.get("/suppliers/search", async (req, res) => {
  const q = req.query.q;
  const suppliers = await dbo.getDb().execute("SELECT * FROM SUPPLIER");

  for (let supplier of suppliers.rows) {
    const phoneNum = await dbo
      .getDb()
      .execute(
        `SELECT * FROM SUP_PHONE_NUMBERS WHERE S_Code = '${supplier[0]}'`
      );

    let phoneNumsField = "";
    for (let i = 0; i < phoneNum.rows.length; ++i) {
      phoneNumsField += phoneNum.rows[i][1];
      if (i != phoneNum.rows.length - 1) {
        phoneNumsField += ", ";
      }
    }

    supplier.push(phoneNumsField);
  }

  // find match
  const matchedSuppliers = suppliers.rows.filter((supplier) => {
    for (let field of supplier) {
      if (
        typeof field == "string" &&
        field.toLowerCase().indexOf(q.toLowerCase()) !== -1
      ) {
        return true;
      }
    }
  });

  // pagination data
  const limit = 12;
  let page = parseInt(req.query.page);

  if (!page || page < 0) {
    page = 1;
  }

  const startIndex = (page - 1) * limit;
  const endIndex = page * limit;
  const pagin = {};

  if (startIndex > 0) {
    pagin.prev = `/suppliers/search?q=${q}&page=${page - 1}`;
  }

  if (endIndex < matchedSuppliers.length) {
    pagin.next = `/suppliers/search?q=${q}&page=${page + 1}`;
  }
  pagin.suppliers = matchedSuppliers.slice(startIndex, endIndex);
  pagin.limit = limit;
  let pageSize = Math.ceil(matchedSuppliers.length / limit);
  pagin.pages = [];
  for (let i = 0; i < pageSize; ++i) {
    pagin.pages.push(i + 1);
  }

  res.render("suppliers", { pagin });
});

///////////////////////////////////////////////////////////////////// CUSTOMERS /////////////////////////////////////////////////////////////////////
// get all customers (for customer view)
router.get("/customers", async (req, res) => {
  const customers = await dbo.getDb().execute("SELECT * FROM CUSTOMER");

  // pagination data
  const limit = 12;
  let page = parseInt(req.query.page);

  if (!page || page < 0) {
    page = 1;
  }

  const startIndex = (page - 1) * limit;
  const endIndex = page * limit;
  const pagin = {};

  if (startIndex > 0) {
    pagin.prev = `/customers?page=${page - 1}`;
  }

  if (endIndex < customers.rows.length) {
    pagin.next = `/customers?page=${page + 1}`;
  }
  pagin.customers = customers.rows.slice(startIndex, endIndex);
  pagin.limit = limit;
  let pageSize = Math.ceil(customers.rows.length / limit);
  pagin.pages = [];
  for (let i = 0; i < pageSize; ++i) {
    pagin.pages.push(i + 1);
  }

  res.render("customers", { pagin });
});

// 4. Report that provides full information about the order for each category of a customer
router.get("/report/customer", async (req, res) => {
  const query = "";
  const result = await dbo.getDb().execute(query);
  res.send(result);
});

// search
router.get("/customers/search", async (req, res) => {
  const q = req.query.q;
  const customers = await dbo.getDb().execute("SELECT * FROM CUSTOMER");

  // find match
  const matchedCustomers = customers.rows.filter((customer) => {
    for (let field of customer) {
      if (
        typeof field == "string" &&
        field.toLowerCase().indexOf(q.toLowerCase()) !== -1
      ) {
        return true;
      }
    }
  });

  // pagination data
  const limit = 12;
  let page = parseInt(req.query.page);

  if (!page || page < 0) {
    page = 1;
  }

  const startIndex = (page - 1) * limit;
  const endIndex = page * limit;
  const pagin = {};

  if (startIndex > 0) {
    pagin.prev = `/customers/search?q=${q}&page=${page - 1}`;
  }

  if (endIndex < matchedCustomers.length) {
    pagin.next = `/customers/search?q=${q}&page=${page + 1}`;
  }
  pagin.customers = matchedCustomers.slice(startIndex, endIndex);
  pagin.limit = limit;
  let pageSize = Math.ceil(matchedCustomers.length / limit);
  pagin.pages = [];
  for (let i = 0; i < pageSize; ++i) {
    pagin.pages.push(i + 1);
  }

  res.render("customers", { pagin });
});

///////////////////////////////////////////////////////////////////// CATEGORIES /////////////////////////////////////////////////////////////////////
// get all categories (for categories view)
router.get("/categories", async (req, res) => {
  const categories = await dbo.getDb().execute("SELECT * FROM CATEGORY");

  // pagination data
  const limit = 12;
  let page = parseInt(req.query.page);

  if (!page || page < 0) {
    page = 1;
  }

  const startIndex = (page - 1) * limit;
  const endIndex = page * limit;
  const pagin = {};

  if (startIndex > 0) {
    pagin.prev = `/categories?page=${page - 1}`;
  }

  if (endIndex < categories.rows.length) {
    pagin.next = `/categories?page=${page + 1}`;
  }
  pagin.categories = categories.rows.slice(startIndex, endIndex);
  pagin.limit = limit;
  let pageSize = Math.ceil(categories.rows.length / limit);
  pagin.pages = [];
  for (let i = 0; i < pageSize; ++i) {
    pagin.pages.push(i + 1);
  }

  res.render("categories", { pagin });
});

// search
router.get("/categories/search", async (req, res) => {
  const q = req.query.q;
  const categories = await dbo.getDb().execute("SELECT * FROM CATEGORY");

  // find match
  const matchedCategories = categories.rows.filter((category) => {
    for (let field of category) {
      if (
        typeof field == "string" &&
        field.toLowerCase().indexOf(q.toLowerCase()) !== -1
      ) {
        return true;
      }
    }
  });

  // pagination data
  const limit = 12;
  let page = parseInt(req.query.page);

  if (!page || page < 0) {
    page = 1;
  }

  const startIndex = (page - 1) * limit;
  const endIndex = page * limit;
  const pagin = {};

  if (startIndex > 0) {
    pagin.prev = `/categories/search?q=${q}&page=${page - 1}`;
  }

  if (endIndex < matchedCategories.length) {
    pagin.next = `/categories/search?q=${q}&page=${page + 1}`;
  }
  pagin.categories = matchedCategories.slice(startIndex, endIndex);
  pagin.limit = limit;
  let pageSize = Math.ceil(matchedCategories.length / limit);
  pagin.pages = [];
  for (let i = 0; i < pageSize; ++i) {
    pagin.pages.push(i + 1);
  }

  res.render("categories", { pagin });
});

///////////////////////////////////////////////////////////////////// AUTHENTICATION /////////////////////////////////////////////////////////////////////
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

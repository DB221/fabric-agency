const express = require("express");
const session = require("express-session");
const path = require("path");

const indexRouter = require("./routes/routes");
require("dotenv").config();

const app = express();

const port = 3000;

// view engine setup
app.set("views", path.join(__dirname, "views"));
// need to select view engine
// app.set("view engine", "jade");

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, "public")));
app.use(
  session({
    secret: process.env.SECRET_KEY,
    resave: false,
    saveUninitialized: true,
    cookie: { maxAge: 1000 * 60 * 60 * 24 },
  })
);

app.use("/", indexRouter);

app.listen(3000, () => {
  console.log(`App listening on port ${port}`);
});

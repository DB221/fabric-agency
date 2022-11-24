module.exports = {
  auth: (req, res, next) => {
    if (!req.session.userid) {
      return res.status(403).send("No permission");
    }
    next();
  },
};

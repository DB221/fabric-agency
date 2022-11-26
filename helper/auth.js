module.exports = {
  auth: (req, res, next) => {
    if (!req.session.userId) {
      return res.status(403).send("No permission");
    }
    next();
  },
};

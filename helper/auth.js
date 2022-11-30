module.exports = {
  auth: (req, res, next) => {
    if (!req.session.userId) {
      req.flash(
        "dangerMessage",
        "Access denied! You have to log in to have permission!"
      );
      return res.redirect("/login");
    }
    next();
  },
};

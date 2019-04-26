const sanitizeHtml = require("sanitize-html");

const sanitize = dirtyHtml => {
  return sanitizeHtml(dirtyHtml, {
    allowedTags: sanitizeHtml.defaults.allowedTags.concat(["sup", "sub"])
  });
};

export default sanitize;

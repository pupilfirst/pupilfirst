const sanitizeHtml = require("sanitize-html");

const allowedTags = sanitizeHtml.defaults.allowedTags.concat([
  "sup",
  "sub",
  "span"
]);

const allowedCodeClasses = [
  "language-javascript",
  "language-js", // javascript
  "language-css",
  "language-scss",
  "language-ruby",
  "language-reason",
  "language-markup",
  "language-html", // markup
  "language-xml", // markup
  "language-svg", // markup
  "language-mathml" // markup
];

const allowedPreClasses = ["line-numbers"];

const sanitize = dirtyHtml => {
  return sanitizeHtml(dirtyHtml, {
    allowedTags: allowedTags,
    allowedClasses: {
      pre: allowedPreClasses,
      code: allowedCodeClasses
    }
  });
};

export default sanitize;

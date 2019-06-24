const sanitizeHtml = require("sanitize-html");

const sanitizationProfiles = {};

sanitizationProfiles.permissive = [
  "p",
  "h1",
  "h2",
  "h3",
  "h4",
  "h5",
  "h6",
  "em",
  "strong",
  "del",
  "s",
  "ul",
  "ol",
  "li",
  "a",
  "code",
  "pre",
  "blockquote",
  "hr",
  "sup",
  "sub",
  "span"
];

sanitizationProfiles.qna = [
  "p",
  "h1",
  "h2",
  "h3",
  "h4",
  "h5",
  "h6",
  "em",
  "strong",
  "del",
  "s",
  "ul",
  "ol",
  "li",
  "a",
  "code",
  "pre",
  "blockquote",
  "hr",
  "sup",
  "sub",
  "span"
];

sanitizationProfiles.comment = [
  "p",
  "em",
  "strong",
  "del",
  "s",
  "a",
  "code",
  "sup",
  "sub"
];

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
    allowedTags: sanitizationProfiles.permissive,
    allowedClasses: {
      pre: allowedPreClasses,
      code: allowedCodeClasses
    }
  });
};

export default sanitize;

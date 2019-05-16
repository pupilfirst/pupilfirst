const sanitizeHtml = require("sanitize-html");

const allowedTags = sanitizeHtml.defaults.allowedTags.concat([
  "sup",
  "sub",
  "span"
]);

const allowedCodeClasses = [
  "language-reason",
  "language-javascript",
  "language-ruby"
];
const allowedPreClasses = allowedCodeClasses.concat("line-numbers");

console.log(allowedPreClasses);

const allowedSpanClasses = [
  "prism-comment",
  "prism-prolog",
  "prism-doctype",
  "prism-cdata",
  "prism-punctuation",
  "prism-namespace",
  "prism-property",
  "prism-tag",
  "prism-constant",
  "prism-symbol",
  "prism-deleted",
  "prism-boolean",
  "prism-number",
  "prism-selector",
  "prism-attr-name",
  "prism-string",
  "prism-char",
  "prism-builtin",
  "prism-inserted",
  "prism-operator",
  "prism-entity",
  "prism-url",
  "language-css ",
  "prism-style ",
  "prism-variable",
  "prism-atrule",
  "prism-attr-value",
  "prism-function",
  "prism-class-name",
  "prism-keyword",
  "prism-regex",
  "prism-important",
  "prism-bold",
  "prism-italic"
];

const sanitize = dirtyHtml => {
  return sanitizeHtml(dirtyHtml, {
    allowedTags: allowedTags,
    allowedClasses: {
      pre: allowedPreClasses,
      code: allowedCodeClasses,
      span: ["line-numbers-rows"]
    },
    allowedAttributes: {
      span: ["aria-hidden"]
    }
  });
};

export default sanitize;

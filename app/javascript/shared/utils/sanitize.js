const sanitizeHtml = require("sanitize-html");

const allowedTags = sanitizeHtml.defaults.allowedTags.concat([
  "sup",
  "sub",
  "span"
]);

const allowedCodeClasses = [
  "language-reasonml",
  "language-ruby",
  "language-javascript",
  "hljs"
];

const allowedSpanClasses = [
  "hljs-keyword",
  "hljs-comment",
  "hljs-quote",
  "hljs-selector-tag",
  "hljs-subst",
  "hljs-number",
  "hljs-literal",
  "hljs-variable",
  "hljs-template-variable",
  "hljs-tag .hljs-attr",
  "hljs-string",
  "hljs-doctag",
  "hljs-title",
  "hljs-section",
  "hljs-selector-id",
  "hljs-type",
  "hljs-class",
  "hljs-tag",
  "hljs-name",
  "hljs-attribute",
  "hljs-regexp",
  "hljs-link",
  "hljs-symbol",
  "hljs-bullet",
  "hljs-built_in",
  "hljs-builtin-name",
  "hljs-meta ",
  "hljs-deletion",
  "hljs-addition",
  "hljs-emphasis",
  "hljs-strong",
  "hljs-function",
  "hljs-template-tag",
  "hljs-meta"
];

const sanitize = dirtyHtml => {
  return sanitizeHtml(dirtyHtml, {
    allowedTags: allowedTags,
    allowedClasses: {
      code: allowedCodeClasses,
      span: allowedSpanClasses
    }
  });
};

export default sanitize;

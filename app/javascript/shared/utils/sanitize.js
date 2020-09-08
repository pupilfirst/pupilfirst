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
  "span",
  "br",
  "img",
  "table",
  "thead",
  "tr",
  "th",
  "td",
  "tbody",
];

sanitizationProfiles.questionAndAnswer = sanitizationProfiles.permissive;

sanitizationProfiles.comment = [
  "p",
  "em",
  "strong",
  "del",
  "s",
  "a",
  "code",
  "sup",
  "sub",
];

sanitizationProfiles.areaOfText = [
  "p",
  "em",
  "strong",
  "del",
  "s",
  "a",
  "sup",
  "sub",
];

const allowedCodeClasses = [
  "language-javascript",
  "language-js", // javascript
  "language-css",
  "language-scss",
  "language-ruby",
  "language-erb",
  "language-reason",
  "language-markup",
  "language-html", // markup
  "language-xml", // markup
  "language-svg", // markup
  "language-mathml", // markup
  "language-yaml",
  "language-yml", //yaml
];

const sanitizationProfile = (profile) => {
  if (profile in sanitizationProfiles) {
    return sanitizationProfiles[profile];
  } else {
    return [];
  }
};

const allowedPreClasses = ["line-numbers"];

const sanitize = (profile, dirtyHtml) => {
  return sanitizeHtml(dirtyHtml, {
    allowedTags: sanitizationProfile(profile),
    allowedAttributes: {
      a: ["href", "name", "target"],
      img: ["src", "title", "alt", "width", "height", "align"],
      td: ["rowspan", "colspan"],
    },
    allowedClasses: {
      pre: allowedPreClasses,
      code: allowedCodeClasses,
    },
  });
};

export default sanitize;

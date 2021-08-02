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
  "div",
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

const languages = [
  "javascript",
  "js",
  "json",
  "webmanifest",
  "markup",
  "html",
  "xml",
  "svg",
  "mathml",
  "css",
  "scss",
  "sql",
  "python",
  "py",
  "java",
  "bash",
  "shell",
  "csharp",
  "cs",
  "dotnet",
  "php",
  "typescript",
  "ts",
  "cpp",
  "c",
  "go",
  "kotlin",
  "kt",
  "kts",
  "ruby",
  "rb",
  "erb",
  "reason",
  "markdown",
  "md",
  "yaml",
  "yml",
];

const allowedCodeClasses = languages
  .map((l) => "language-" + l)
  .concat(languages.map((l) => "language-diff-" + l))
  .concat(["language-diff", "diff-highlight"]);

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
      div: ["align"],
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

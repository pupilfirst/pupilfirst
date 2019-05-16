import Prism from "prismjs";

require("./prism-okaidia.css");

Prism.plugins.customClass.prefix("prism-");

import commonmarkPreset from "markdown-it/lib/presets/commonmark";

const md = require("markdown-it")({
  ...commonmarkPreset.options,
  langPrefix: "line-numbers language-",
  highlight: function(str, lang) {
    const prismLang = Prism.languages[lang];

    if (lang && prismLang) {
      try {
        const highlightedCode = Prism.highlight(str, prismLang, lang);
        console.log(highlightedCode);
        return highlightedCode;
      } catch (__) {}
    }

    return ""; // use external default escaping
  }
});

md.use(require("markdown-it-sub")).use(require("markdown-it-sup"));

const parse = markdown => {
  return md.render(markdown);
};

export default parse;

import hljs from "highlight.js/lib/highlight";

import reasonml from "highlight.js/lib/languages/reasonml";
import ruby from "highlight.js/lib/languages/ruby";
import javascript from "highlight.js/lib/languages/javascript";

hljs.registerLanguage("reasonml", reasonml);
hljs.registerLanguage("ruby", ruby);
hljs.registerLanguage("javascript", javascript);

import "highlight.js/styles/monokai-sublime.css";

import commonmarkPreset from "markdown-it/lib/presets/commonmark";

const md = require("markdown-it")({
  ...commonmarkPreset.options,
  langPrefix: "hljs language-",
  highlight: function(str, lang) {
    if (lang && hljs.getLanguage(lang)) {
      try {
        return hljs.highlight(lang, str).value;
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

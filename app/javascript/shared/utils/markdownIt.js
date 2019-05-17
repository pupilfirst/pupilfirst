import commonmarkPreset from "markdown-it/lib/presets/commonmark";

const md = require("markdown-it")({
  ...commonmarkPreset.options,
  highlight: (str, lang) => {
    return (
      '<pre class="line-numbers"><code class="language-' +
      lang +
      '">' +
      md.utils.escapeHtml(str) +
      "</code></pre>"
    );
  }
});

md.use(require("markdown-it-sub")).use(require("markdown-it-sup"));

const parse = markdown => {
  return md.render(markdown);
};

export default parse;

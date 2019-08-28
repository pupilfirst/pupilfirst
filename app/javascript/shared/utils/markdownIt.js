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

const subscriptPlugin = require("markdown-it-sub");
const superscriptPlugin = require("markdown-it-sup");
const tablePlugin = require("markdown-it-multimd-table");

md.use(subscriptPlugin)
  .use(superscriptPlugin)
  .use(tablePlugin);

const parse = markdown => {
  return md.render(markdown);
};

export default parse;

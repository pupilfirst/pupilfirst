import commonmarkPreset from "markdown-it/lib/presets/commonmark";

const md = require("markdown-it")({
  ...commonmarkPreset.options,
  linkify: true,
  highlight: (str, lang) => {
    return (
      '<pre class="line-numbers"><code class="language-' +
      lang +
      '">' +
      md.utils.escapeHtml(str) +
      "</code></pre>"
    );
  },
});

const subscriptPlugin = require("markdown-it-sub");
const superscriptPlugin = require("markdown-it-sup");
const tablePlugin = require("markdown-it-multimd-table");
const linkifyImagesPlugin = require("markdown-it-linkify-images");
const imageSizePlugin = require('@centerforopenscience/markdown-it-imsize');
const linkAttributesPlugin = require('markdown-it-link-attributes')

md.use(subscriptPlugin)
  .use(superscriptPlugin)
  .use(tablePlugin)
  .use(imageSizePlugin)
  .use(linkAttributesPlugin, {
    attrs: {
      target: '_blank',
    }
  })
  .use(linkifyImagesPlugin, {
    target: "_blank",
  });

const parse = (markdown) => {
  return md.render(markdown);
};

export default parse;

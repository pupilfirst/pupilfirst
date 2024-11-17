import commonmarkPreset from "markdown-it/lib/presets/commonmark";

import markdownIt from "markdown-it";
import subscriptPlugin from "markdown-it-sub";
import superscriptPlugin from "markdown-it-sup";
import tablePlugin from "markdown-it-multimd-table";
import linkifyImagesPlugin from "markdown-it-linkify-images";
import imageSizePlugin from "@centerforopenscience/markdown-it-imsize";
import linkAttributesPlugin from "markdown-it-link-attributes";
import katexPlugin from "@vscode/markdown-it-katex";
import alignPlugin from "markdown-it-align";
import checkboxPlugin from "markdown-it-task-checkbox";
import videoPlugin from "markdown-it-video";

const md = markdownIt({
  ...commonmarkPreset.options,
  html: false,
  linkify: true,
  highlight: (str, lang) => {
    const lineNumbersClass = lang.startsWith("diff") ? "" : "line-numbers";
    const highlightClass = lang.endsWith("-highlight") ? "diff-highlight" : "";
    const langWithoutHighlight = lang.replace(/-highlight$/, "");

    return (
      '<pre class="' +
      lineNumbersClass +
      '"><code class="language-' +
      langWithoutHighlight +
      " " +
      highlightClass +
      '">' +
      md.utils.escapeHtml(str) +
      "</code></pre>"
    );
  },
});

md.use(videoPlugin, {
  youtube: { width: "100%", height: 384 },
  vimeo: { width: "100%", height: 489 },
})
  .use(subscriptPlugin)
  .use(superscriptPlugin)
  .use(tablePlugin)
  .use(imageSizePlugin)
  .use(linkAttributesPlugin, {
    attrs: {
      target: "_blank",
    },
  })
  .use(linkifyImagesPlugin, {
    target: "_blank",
  })
  .use(katexPlugin)
  .use(alignPlugin)
  .use(checkboxPlugin, {
    disabled: true,
    liClass: "flex items-center gap-2 -ms-10",
    ulClass: "list-none",
  });

const parse = (markdown) => {
  return md.render(markdown);
};

export default parse;

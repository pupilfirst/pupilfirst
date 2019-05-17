import commonmarkPreset from "markdown-it/lib/presets/commonmark";

const md = require("markdown-it")({
  ...commonmarkPreset.options,
  langPrefix: "line-numbers language-"
});

md.use(require("markdown-it-sub")).use(require("markdown-it-sup"));

const parse = markdown => {
  return md.render(markdown);
};

export default parse;

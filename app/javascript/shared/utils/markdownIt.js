const markdownIt = require("markdown-it")("commonmark")
  .use(require("markdown-it-sub"))
  .use(require("markdown-it-sup"));

const parse = markdown => {
  return markdownIt.render(markdown);
};

export default parse;

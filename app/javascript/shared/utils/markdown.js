import marked from "marked";

const parse = markdown => {
  return marked(markdown, { sanitize: true });
};

export default parse;

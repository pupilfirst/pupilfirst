import Fuse from "fuse.js";

const options = {
  includeScore: true,
  keys: ["text"],
};

const search = (input, selectable) => {
  const fuse = new Fuse(selectable, options);
  return fuse.search(input).map((p) => p.item);
};

export default search;

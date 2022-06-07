import "~/home/index.css";
import { parseMarkdown } from "~/packs/ConvertMarkdownPack.bs.js";
import { match } from "~/shared/utils/Psj.bs.js";

match("home#index", () => {
  parseMarkdown();
});

import "~/home/assets/index.css";
import { parseMarkdown } from "~/packs/ConvertMarkdownPack.bs.js";
import { match } from "~/shared/utils/Psj.bs.js";

match(true, "home#index", () => {
  parseMarkdown();
});

import "~/home/assets/index.css";
import { parseMarkdown } from "~/packs/ConvertMarkdownPack.res.mjs";
import { match } from "~/shared/utils/Psj.res.mjs";

match(true, "home#index", () => {
  parseMarkdown();
});

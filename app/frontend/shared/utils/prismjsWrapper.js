import Prism from "prismjs";
import "prismjs/plugins/custom-class/prism-custom-class";

// Include a clone of the 'Okaidia' theme CSS with prefixed classes.
import "./prism-okaidia.css";

// Inlude a clone of the 'diff-highlight' plugin CSS with prefixed classes.
import "./prism-diff-highlight.css";

/*
 * Prevent Prism from highlighting all eligible code blocks in the DOM upon
 * page load - its default behavior. It sets up an event listener as soon as
 * its lib code is evaluated, so the only option at this point is to remove
 * the listener.
 */
document.removeEventListener("DOMContentLoaded", Prism.highlightAll);

// Use the custom-class plugin to instruct Prism to prefix all generated classes with 'prism-'.
document.addEventListener(
  "DOMContentLoaded",
  () => {
    Prism.plugins.customClass.prefix("prism-");
  },
  false
);

const highlightAllUnder = (element) => Prism.highlightAllUnder(element);

export default highlightAllUnder;

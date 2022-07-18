import Prism from "prismjs";
import "prismjs/plugins/custom-class/prism-custom-class";

// Include a clone of the 'Okaidia' theme CSS with prefixed classes.
import "./prism-okaidia.css";

// Inlude a clone of the 'diff-highlight' plugin CSS with prefixed classes.
import "./prism-diff-highlight.css";

// Include a clone of the 'Okaidia' theme CSS with prefixed classes.
import "./prism-okaidia.css";

// Inlude a clone of the 'diff-highlight' plugin CSS with prefixed classes.
import "./prism-diff-highlight.css";

// Use the custom-class plugin to instruct Prism to prefix all generated classes with 'prism-'.
Prism.plugins.customClass.prefix("prism-");

const highlightAllUnder = (element) => Prism.highlightAllUnder(element);

export default highlightAllUnder;

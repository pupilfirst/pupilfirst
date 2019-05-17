import Prism from "prismjs";

// Prevent Prism from highlighting all eligible code blocks in the DOM upon page load - its default behavior.
// There is one other way to disable this behavior - to set Prism.manual to false before
document.removeEventListener("DOMContentLoaded", Prism.highlightAll);

// Use the custom-class plugin to instruct Prism to prefix all generated classes with 'prism-'.
Prism.plugins.customClass.prefix("prism-");

// Include a clone of the 'Okaidia' theme CSS with prefixed classes.
require("./prism-okaidia.css");

const highlightAllUnder = element => Prism.highlightAllUnder(element);

export default highlightAllUnder;

import "./pupilFirstIcons.css";
let iconData = require("./svgPaths.json");

function getIconData(iconName) {
  let data = iconData[iconName];
  return data ? data : iconData["default"];
}

function viewboxClass(width) {
  switch (width) {
    case 448:
      return " pfi-w-14"
    case 576:
      return " pfi-w-18"
    case 640:
      return " pfi-w-20"
    default:
      return " pfi-w-16"
  };
}

function createSvg(className) {
  const xmlns = "http://www.w3.org/2000/svg";
  const title = title;
  const icon = getIconData(className.match(/pf-([a-zA-z0-9\-]+)/)[1]);
  const el = document.createElementNS(xmlns, "svg");
  el.setAttribute("class", className.replace("pfi", "pfi-svg-icon__baseline").concat(viewboxClass(icon[0])));
  el.setAttribute("role", "img");
  el.setAttribute("xmlns", xmlns);
  el.setAttribute("viewBox", "0 0 ".concat(icon[0]).concat(" 512"));

  const path = document.createElementNS(xmlns, "path");
  path.setAttribute("fill", "currentColor");
  path.setAttribute("d", icon[1]);
  el.appendChild(path);
  return el;
}

document.addEventListener("DOMContentLoaded", function () {
  const elements = Array.from(document.getElementsByClassName("pfi"));
  elements.map(element => {
    if (element.tagName == "I") {
      element.parentNode.replaceChild(createSvg(element.className), element);
    }
  });
});

let iconData = require("./svgPaths.json");

function getIconData(iconName) {
  let data = iconData[iconName];
  return data ? data : iconData["default"];
}

function createSvg(className) {
  const xmlns = "http://www.w3.org/2000/svg";
  const icon = getIconData(className.match(/pf-([a-zA-z0-9\-]+)/)[1]);
  el = document.createElementNS(xmlns, "svg");
  el.setAttribute("viewBox", "0 0 ".concat(icon[0]).concat(" 512"));
  el.setAttribute("class", className.replace("pfi", "svg-inline--fa"));
  el.setAttribute("xmlns", xmlns);

  path = document.createElementNS(xmlns, "path");
  path.setAttribute("fill", "currentColor");
  path.setAttribute("d", icon[1]);
  el.appendChild(path);
  return el;
}

document.addEventListener("DOMContentLoaded", function() {
  const elements = Array.from(document.getElementsByClassName("pfi"));
  elements.map(element => {
    if (element.tagName == "I") {
      element.parentNode.replaceChild(createSvg(element.className), element);
    }
  });
});

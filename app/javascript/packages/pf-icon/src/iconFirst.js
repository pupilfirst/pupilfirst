import "./iconFirst.css";
let iconData = require("./data/paths.json");

const xmlns = "http://www.w3.org/2000/svg";

const findIconName = className => {
  const iconName = className.match(/i-([a-zA-z0-9\-]+)/);
  return iconName ? iconName[1] : "default";
};

const getIconData = className => {
  const data = iconData[findIconName(className)];
  return data ? data : iconData["default"];
};

const viewboxClass = width => {
  switch (width) {
    case 320:
      return " if-w-10";
    case 384:
      return " if-w-12";
    case 448:
      return " if-w-14";
    case 576:
      return " if-w-18";
    case 640:
      return " if-w-20";
    default:
      return " if-w-16";
  }
};

const createSvg = className => {
  const icon = getIconData(className);
  const el = document.createElementNS(xmlns, "svg");
  el.setAttribute(
    "class",
    className
      .replace("if", "if-svg-icon__baseline")
      .concat(viewboxClass(icon[0]))
  );
  el.setAttribute("role", "img");
  el.setAttribute("xmlns", xmlns);
  el.setAttribute("viewBox", "0 0 ".concat(icon[0]).concat(" 512"));

  const path = document.createElementNS(xmlns, "path");
  path.setAttribute("fill", "currentColor");
  path.setAttribute("d", icon[1]);
  el.appendChild(path);
  return el;
};

export const transformIcons = () => {
  const elements = Array.from(document.getElementsByClassName("if"));
  elements.forEach(element => {
    if (element.tagName == "I") {
      element.parentNode.replaceChild(createSvg(element.className), element);
    }
  });
};

export const addListener = () =>
  document.addEventListener("DOMContentLoaded", transformIcons);

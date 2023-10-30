let colorSelector;

if (window.location.href.includes("school/standings/")) {
  window.addEventListener("load", setShieldColor, false);
}

function setShieldColor() {
  colorSelector = document.getElementById("color_picker");
  if (colorSelector) {
    colorSelector.addEventListener("change", update, false);
  }
}

function update(event) {
  let content = document.getElementById("shield_svg");
  content.setAttribute("fill", event.target.value);
}

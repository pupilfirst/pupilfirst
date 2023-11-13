/*
   TODO: If this code breaks after enabling turbo, we need to move this code to stimulus controller
*/

// This code is used to set the color of the shield in the school standings edit/new page
if (window.location.href.includes("school/standings/")) {
  window.addEventListener("load", setShieldColor, false);
}

function setShieldColor() {
  let colorSelector = document.getElementById("color_picker");
  if (colorSelector) {
    colorSelector.addEventListener("change", update, false);
  }
}

function update(event) {
  let innerShield = document.getElementById("inner_shield");
  let outerShield = document.getElementById("outer_shield");
  innerShield.setAttribute("fill", event.target.value);
  outerShield.setAttribute("fill", event.target.value);
}

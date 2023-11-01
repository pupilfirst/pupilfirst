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

if (window.location.href.includes("/school/standing")) {
  window.addEventListener("load", deleteStanding, false);
  console.log("delete standing");
}

function deleteStanding() {
  let deleteButtons = document.getElementsByClassName("delete_button");
  for (let i = 0; i < deleteButtons.length; i++) {
    deleteButtons[i].addEventListener("click", function (event) {
      if (!confirm("Are you sure you want to delete this standing?")) {
        event.preventDefault();
      }
    });
  }
}

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
  let content = document.getElementById("shield_svg");
  content.setAttribute("fill", event.target.value);
}

//  This code is used to confirm the delete action for standings in the school standing page.
//  Once turbo is enabled, we can directly use the data-confirm attribute in the delete button
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

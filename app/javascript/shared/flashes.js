import Notify from "./notifier";

function capitalizeFirstLetter(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

document.addEventListener("DOMContentLoaded", function() {
  const message = JSON.parse(
    document.documentElement.getAttribute("data-flash")
  );
  message.map(flash);

  function flash(flash) {
    var type;
    switch (flash.type) {
      case "success":
        type = "success";
        break;
      case "error":
        type = "error";
        break;
      default:
        type = "notice";
        break;
    }
    Notify(capitalizeFirstLetter(type), flash.message, type);
  }
});

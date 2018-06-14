import Tilt from "vanilla-tilt";

$(document).on("turbolinks:load", () => {
  if ($(window).width() >= 1024) {
    const element = document.querySelector(".js-tilt");
    Tilt.init(element);
  }
});

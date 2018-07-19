import Tilt from "vanilla-tilt";
import "../../home/fb.css"

$(document).on("turbolinks:load", () => {
  if ($(window).width() >= 1024) {
    const element = document.querySelector(".js-tilt");
    Tilt.init(element);
  }
});

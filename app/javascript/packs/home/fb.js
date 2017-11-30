import Tilt from 'vanilla-tilt'

$(document).on('turbolinks:load', () => {
  const element = document.querySelector(".js-tilt");
  Tilt.init(element);
});

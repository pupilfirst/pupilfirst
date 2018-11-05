import Tilt from "vanilla-tilt";
import "../../home/fb.css"

$(document).on("turbolinks:load", () => {
  // Super cool tilt animation on our fb page
  if ($(window).width() >= 1024) {
    const element = document.querySelector(".js-tilt");
    Tilt.init(element);
  }

  // Typeform embed for VR101 application: www.sv.co/fb?apply=now
  (function() { var qs,js,q,s,d=document, gi=d.getElementById, ce=d.createElement, gt=d.getElementsByTagName, id="typef_orm_share", b="https://embed.typeform.com/"; if(!gi.call(d,id)){ js=ce.call(d,"script"); js.id=id; js.src=b+"embed.js"; q=gt.call(d,"script")[0]; q.parentNode.insertBefore(js,q) } })()

});

import Notify from "./notifier";

import { t as I18n_t } from "./utils/I18n.bs.js";

var partial_arg = "shared";

function t(param, param$1, param$2) {
  return I18n_t(partial_arg, param, param$1, param$2);
}

document.addEventListener("DOMContentLoaded", function () {
  const message = JSON.parse(
    document.documentElement.getAttribute("data-flash")
  );
  message.map(flash);

  function flash(flash) {
    var type;
    var heading;
    switch (flash.type) {
      case "success":
        type = "success";
        heading = t(undefined, undefined, "notifications.success");
        break;
      case "error":
        type = "error";
        heading = t(undefined, undefined, "notifications.error");
        break;
      default:
        type = "notice";
        heading = t(undefined, undefined, "notifications.notice");
        break;
    }
    Notify(heading, flash.message, type);
  }
});

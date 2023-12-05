import { alert, defaultModules, Stack } from "@pnotify/core";
import "@pnotify/core/dist/PNotify.css";
import * as PNotifyMobile from "@pnotify/mobile";
import "@pnotify/mobile/dist/PNotifyMobile.css";
import "./notifier.css";

const notify = (title, text, type) => {
  let notificationText = text;
  let textTrusted = false;
  let reloadRequired = false;

  if (text.includes("reload") || text.includes("refresh")) {
    let url = window.location.href;
    notificationText =
      "<div>" +
      text +
      "<div><button class='btn btn-secondary mt-4'>Refresh Page</button></div></div>";
    textTrusted = true;
    reloadRequired = true;
  }

  const notificationContainer = document.getElementById("notifications");
  document.body.appendChild(notificationContainer);

  const notification = alert({
    type: type,
    title: title,
    text: notificationText,
    textTrusted: textTrusted,
    styling: "custom",
    icons: "custom",
    mode: "light",
    addClass: "mb-4",
    maxTextHeight: null,
    closer: true,
    sticker: false,
    delay: 6000,
    stack: new Stack({
      context: notificationContainer,
      dir1: "down",
      dir2: "left",
      firstpos1: 0,
      firstpos2: 0,
      push: "down",
      spacing1: 0,
      spacing2: 0,
      maxStrategy: 'wait',
      maxOpen: 6,
      modal: false,
    }),
    modules: new Map([...defaultModules, [PNotifyMobile, {}]]),
  });

  notification.refs.elem.addEventListener("click", () => {
    notification.close();

    if (reloadRequired) window.location.reload();
  });
};

export default notify;

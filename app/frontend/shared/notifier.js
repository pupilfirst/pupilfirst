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
      "<div><button class='btn btn-secondary mt-4'>Reload Page</button></div></div>";
    textTrusted = true;
    reloadRequired = true;
  }

  if (typeof window.notificationStack === "undefined") {
    window.notificationStack = new Stack({
      dir1: "down",
      dir2: "left",
      firstpos1: 20,
      firstpos2: 20,
      spacing1: 20,
      spacing2: 20,
      push: "top",
      modal: false,
      maxOpen: 6,
      maxStrategy: "close",
      maxClosureCausesWait: false,
    });
  }

  const notification = alert({
    type: type,
    title: title,
    text: notificationText,
    textTrusted: textTrusted,
    styling: "custom",
    icons: "custom",
    mode: "light",
    maxTextHeight: null,
    closer: true,
    sticker: false,
    delay: 6000,
    stack: window.notificationStack,
    modules: new Map([...defaultModules, [PNotifyMobile, {}]]),
  });

  notification.refs.elem.addEventListener("click", () => {
    notification.close();

    if (reloadRequired) window.location.reload();
  });
};

export default notify;

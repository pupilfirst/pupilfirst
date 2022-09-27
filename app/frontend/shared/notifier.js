import { alert, defaultModules } from "@pnotify/core";
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
    modules: new Map([...defaultModules, [PNotifyMobile, {}]]),
  });

  notification.refs.elem.addEventListener("click", () => {
    notification.close();

    if (reloadRequired) window.location.reload();
  });
};

export default notify;

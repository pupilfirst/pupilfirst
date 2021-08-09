import PNotify from "pnotify/dist/es/PNotify";
import "pnotify/dist/PNotifyBrightTheme.css";

const notify = (title, text, type) => {
  let notificationText = text;
  let textTrusted = false;
  let reloadRequired = false;

  if (text.includes("reload") || text.includes("refresh")) {
    let url = window.location.href;
    notificationText =
      "<div>" +
      text +
      "<button class='btn btn-secondary mt-1'><i class='fas fa-redo'></i></button></div>";
    textTrusted = true;
    reloadRequired = true;
  }

  const notification = PNotify.alert({
    type: type,
    title: title,
    text: notificationText,
    textTrusted: textTrusted,
    styling: "brighttheme",
    buttons: {
      closer: false,
      sticker: false,
    },
  });

  notification.refs.elem.addEventListener("click", () => {
    notification.close();

    if (reloadRequired) window.location.reload();
  });
};

export default notify;

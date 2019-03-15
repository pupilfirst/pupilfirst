import PNotify from "pnotify/dist/es/PNotify";
import "pnotify/dist/PNotifyBrightTheme.css";

const notify = (title, text, type) => {
  const notification = PNotify.alert({
    type: type,
    title: title,
    text: text,
    styling: "brighttheme",
    buttons: {
      closer: false,
      sticker: false
    }
  });
  notification.refs.elem.addEventListener("click", () => {
    notification.close();
  });
};

export default notify;

import "layouts/tailwind.css";
import "shared/utils/rollbar.js"
import "@fortawesome/fontawesome-free/js/all.js"
import "shared/flashes.js"
import "shared/serviceWorkerRegisterer.js"
import I18n from "i18n-js";

global.I18n = I18n;

require("@rails/ujs").start();

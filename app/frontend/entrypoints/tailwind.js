import "~/layouts/tailwind.css";
import "@fortawesome/fontawesome-free/js/all.js";
import "~/shared/flashes.js";
import "~/shared/serviceWorkerRegisterer.js";
import "~/shared/i18n.js";
import * as IconFirst from "../packages/pf-icon/src/iconFirst.js";
import Rails from "@rails/ujs";

Rails.start();
IconFirst.addListener();

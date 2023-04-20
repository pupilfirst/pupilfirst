import Rails from "@rails/ujs";

// Common styles
import "~/layouts/tailwind.css";
import "~/shared/styles/background_patterns.css";

// Common JavaScript
import "@fortawesome/fontawesome-free/js/all.js";
import "~/shared/flashes.js";
import "~/shared/serviceWorkerRegisterer.js";
import "~/shared/i18n.js";
import * as IconFirst from "../packages/pf-icon/src/iconFirst.js";
import "~/shared/reComponentLoader.js";

IconFirst.addListener();

import { I18n } from "i18n-js";
import translations from "../locales.json";

const i18n = new I18n(translations);

i18n.enableFallback = true;
i18n.missingTranslationPrefix = "Missing translation: ";
i18n.defaultLocale = window.pupilfirst.defaultLocale;
i18n.locale = window.pupilfirst.locale;

export default i18n;

import { I18n } from "i18n-js";
import translations from "../locales.json";

const i18n = new I18n();

i18n.store(translations);
i18n.defaultLocale = "en";
i18n.enableFallback = true;
i18n.locale = window.pupilfirst.locale;
i18n.missingTranslationPrefix = "Missing translation: ";

export default i18n;

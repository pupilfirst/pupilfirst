import { I18n } from "i18n-js";
import translations from "../locales.json";

const i18n = new I18n();

i18n.store(translations);

// i18n-js uses the default locale only as the fallback locale. "en" is the safe choice for this.
i18n.defaultLocale = "en";
i18n.enableFallback = true;

// Set the locale to the locale selected by the server - this takes server's choice for default locale into account.
i18n.locale = window.pupilfirst.locale;
i18n.missingTranslationPrefix = "Missing translation: ";

export default i18n;

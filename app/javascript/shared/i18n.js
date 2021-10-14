import { I18n } from "i18n-js";
import translations from "locales.json";

export const i18n = new I18n(translations);

i18n.enableFallback = true;
i18n.missingTranslationPrefix = "Missing translation: ";

global.i18n = i18n;

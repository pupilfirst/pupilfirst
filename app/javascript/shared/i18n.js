import I18n from "i18n-js";

I18n.originalMissingTranslation = I18n.missingTranslation;

I18n.missingTranslation = (scope, options) => {
  console.error("Missing translation " + scope)
  return I18n.originalMissingTranslation(scope, options);
};

global.I18n = I18n;

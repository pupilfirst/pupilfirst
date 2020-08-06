/*
 * let tc = T.make("components.CourseCertificates__Root")
 * let label = tc->T.t("create_button")
 */

type config = {scope: string};

let make = scope => {scope: scope};

[@bs.scope "I18n"] [@bs.val]
external translate: string => string = "translate";
[@bs.scope "I18n"] [@bs.val]
external translateWithOptions: (string, Js.t('a)) => string = "translate";

let t = (config, identifier) => translate(config.scope ++ "." ++ identifier);
let ts = (config, identifier) => t(config, identifier)->React.string;
let tOpt = (config, identifier, options) =>
  translateWithOptions(config.scope ++ "." ++ identifier, options);
let tsOpt = (config, identifier, options) =>
  tOpt(config, identifier, options)->React.string;

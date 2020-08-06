/*
 * let tc = I18n.t(~scope="components.CourseCertificates__Root")
 * let label = tc("create_button")
 */

type key = string;
type value = string;

[@bs.scope "I18n"] [@bs.val]
external translate: (string, Js.Dict.t('a)) => string = "translate";

let t2 = (~scope="", ~options, identifier) =>
  translate(scope ++ "." ++ identifier, options);

let arrayToJsOptions = options => {
  let dict = Js.Dict.empty();

  Belt.Array.forEach(options, ((key, value)) => {
    Js.Dict.set(dict, key, value)
  });

  dict;
};

let t = (~scope="", ~options: array((key, value))=[||], identifier) => {
  let jsOptions = arrayToJsOptions(options);
  translate(scope ++ "." ++ identifier, jsOptions);
};

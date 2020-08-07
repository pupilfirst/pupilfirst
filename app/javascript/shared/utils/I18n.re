/*
 * let tc = I18n.t(~scope="components.CourseCertificates__Root")
 * let ts = I18n.t(~scope="shared")
 * let label = tc("create_button")
 * let cancel = ts("cancel")
 */

type key = string;
type value = string;

[@bs.scope "I18n"] [@bs.val]
external translate: (string, Js.Dict.t('a)) => string = "translate";

let arrayToJsOptions = options => {
  let dict = Js.Dict.empty();

  Belt.Array.forEach(options, ((key, value)) => {
    Js.Dict.set(dict, key, value)
  });

  dict;
};

let addCount = (jsDict, count) => {
  Belt.Option.forEach(count, count =>
    Js.Dict.set(jsDict, "count", count->string_of_int)
  );

  jsDict;
};

let t =
    (~scope=?, ~variables: array((key, value))=[||], ~count=?, identifier) => {
  let jsOptions = arrayToJsOptions(variables)->addCount(count);

  let fullIdentifier =
    switch (scope) {
    | Some(scope) => scope ++ "." ++ identifier
    | None => identifier
    };

  translate(fullIdentifier, jsOptions);
};

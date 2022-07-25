/*
 * let tc = I18n.t(~scope="components.CourseCertificates__Root")
 * let ts = I18n.t(~scope="shared")
 * let label = tc("create_button")
 * let cancel = ts("cancel")
 */

type key = string
type value = string

type options = {
  count: option<int>,
  defaults: array<Js.Dict.t<string>>,
}

// type i18n = {
//   t:  => string
// }
type i18n;

@module("~/shared/i18n") external i18n: i18n = "default"
@send external translate: (i18n, string, Js.t<'a>) => string = "t";

external optionsToJsObject: options => Js.t<'a> = "%identity"
external variablesToJsObject: Js.Dict.t<string> => Js.t<'a> = "%identity"

let mergeOptionsAndVariables = (options, variables) => {
  let optionsObject = optionsToJsObject(options)
  let variablesObject = variablesToJsObject(variables)

  Js.Obj.assign(optionsObject, variablesObject)
}

let options = (~count, identifier) => {
  let defaultScope = Js.Dict.fromArray([("scope", "shared." ++ identifier)])
  {count: count, defaults: [defaultScope]}
}

let t = (~scope=?, ~variables: array<(key, value)>=[], ~count=?, identifier) => {
  let fullOptions = mergeOptionsAndVariables(
    options(~count, identifier),
    Js.Dict.fromArray(variables),
  )

  let fullIdentifier = switch scope {
  | Some(scope) => scope ++ ("." ++ identifier)
  | None => identifier
  }

  translate(i18n, fullIdentifier, fullOptions)
}

let ts = (~variables: array<(key, value)>=[], ~count=?, identifier) =>
  t(~scope="shared", ~variables, ~count?, identifier)

exception DataElementMissing(string)
exception RootElementMissing(string)
exception RootAttributeMissing(string)

open Webapi.Dom

let parseJSONTag = (~id="react-root-data", ()) =>
  Js.Json.parseExn(
    switch document->Document.getElementById(id) {
    | Some(rootElement) => Element.innerHTML(rootElement)
    | None => raise(DataElementMissing(id))
    },
  )

let parseJSONAttribute = (~id="react-root", ~attribute="data-json-props", ()) =>
  Js.Json.parseExn(
    switch document->Document.getElementById(id) {
    | Some(rootElement) =>
      switch rootElement->Element.getAttribute(attribute) {
      | Some(props) => props
      | None => raise(RootAttributeMissing(attribute))
      }
    | None => raise(RootElementMissing(id))
    },
  )

let redirect = path => Webapi.Dom.Window.setLocation(window, path)

let reload = () => Location.reload(location)

let isDevelopment = () =>
  switch document->Document.documentElement->Element.getAttribute("data-env") {
  | Some(props) if props == "development" => true
  | Some(_)
  | None => false
  }

let goBack = () => History.back(Window.history(window))

let getUrlParam = (~key) =>
  window
  ->Window.location
  ->Location.search
  ->Webapi.Url.URLSearchParams.make
  ->Webapi.Url.URLSearchParams.get(key)

let hasUrlParam = (~key) => getUrlParam(~key)->Belt.Option.isSome

module FormData = {
  type t = Fetch.formData

  @new external create: Dom.element => t = "FormData"
  @send external append: (t, 'a) => unit = "append"
}

module EventTarget = {
  type t = {.}

  /* Be careful when using this function. Event targets need not be an 'element'. */

  external unsafeToElement: t => Dom.element = "%identity"
  external unsafeToHtmlInputElement: t => Dom.htmlInputElement = "%identity"
}

module Event = {
  type t = Dom.event

  @set external setReturnValue: (t, string) => unit = "returnValue"
}

module Element = {
  type t = Dom.element

  external unsafeToHtmlInputElement: t => Dom.htmlInputElement = "%identity"

  let clearFileInput = (~inputId, ~callBack=?, ()) => {
    switch document->Document.getElementById(inputId) {
    | Some(e) => HtmlInputElement.setValue(unsafeToHtmlInputElement(e), "")
    | None => ()
    }

    callBack->Belt.Option.mapWithDefault((), cb => cb())
  }
}

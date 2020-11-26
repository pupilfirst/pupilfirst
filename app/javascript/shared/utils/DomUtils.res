exception DataElementMissing(string)
exception RootElementMissing(string)
exception RootAttributeMissing(string)

open Webapi.Dom

let parseJSONTag = (~id="react-root-data", ()) =>
  switch document |> Document.getElementById(id) {
  | Some(rootElement) => rootElement |> Element.innerHTML
  | None => raise(DataElementMissing(id))
  } |> Json.parseOrRaise

let parseJSONAttribute = (~id="react-root", ~attribute="data-json-props", ()) =>
  switch document |> Document.getElementById(id) {
  | Some(rootElement) =>
    switch rootElement |> Element.getAttribute(attribute) {
    | Some(props) => props
    | None => raise(RootAttributeMissing(attribute))
    }
  | None => raise(RootElementMissing(id))
  } |> Json.parseOrRaise

let redirect = path => path |> Webapi.Dom.Window.setLocation(window)

let reload = () => location |> Location.reload

let isDevelopment = () =>
  switch document |> Document.documentElement |> Element.getAttribute("data-env") {
  | Some(props) when props == "development" => true
  | Some(_)
  | None => false
  }

let goBack = () => window |> Window.history |> History.back

let hasUrlParam = (~key) =>
  (window
  |> Window.location
  |> Location.search
  |> Webapi.Url.URLSearchParams.make
  |> Webapi.Url.URLSearchParams.get(key))->Belt.Option.isSome

module FormData = {
  type t = Fetch.formData

  @bs.new external create: Dom.element => t = "FormData"
  @bs.send external append: (t, 'a) => unit = "append"
}

module EventTarget = {
  type t = {.}

  /* Be careful when using this function. Event targets need not be an 'element'. */

  external unsafeToElement: t => Dom.element = "%identity"
  external unsafeToHtmlInputElement: t => Dom.htmlInputElement = "%identity"
}

module Event = {
  type t = Dom.event

  @bs.set external setReturnValue: (t, string) => unit = "returnValue"
}

module Element = {
  type t = Dom.element

  external unsafeToHtmlInputElement: t => Dom.htmlInputElement = "%identity"
}

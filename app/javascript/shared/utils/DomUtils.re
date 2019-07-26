exception RootElementMissing(string);
exception RootAttributeMissing(string);

open Webapi.Dom;

let parseJsonAttribute = (~id="react-root", ~attribute="data-json-props", ()) =>
  (
    switch (document |> Document.getElementById(id)) {
    | Some(rootElement) =>
      switch (rootElement |> Element.getAttribute(attribute)) {
      | Some(props) => props
      | None => raise(RootAttributeMissing(attribute))
      }
    | None => raise(RootElementMissing(id))
    }
  )
  |> Json.parseOrRaise;

let redirect = path => path |> Webapi.Dom.Window.setLocation(window);

let isDevelopment = () =>
  switch (
    document |> Document.documentElement |> Element.getAttribute("data-env")
  ) {
  | Some(props) when props == "development" => true
  | Some(_)
  | None => false
  };

module FormData = {
  type t = Fetch.formData;

  [@bs.new] external create: Dom.element => t = "FormData";
  [@bs.send] external append: (t, 'a) => unit = "append";
};

module EventTarget = {
  type t = Js.t({.});

  /* Be careful when using this function. Event targets need not be an 'element'. */

  external unsafeToElement: t => Dom.element = "%identity";
};

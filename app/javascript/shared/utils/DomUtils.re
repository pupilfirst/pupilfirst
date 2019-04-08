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
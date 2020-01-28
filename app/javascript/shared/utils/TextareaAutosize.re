open Webapi.Dom;

[@bs.module] external autosize: Dom.element => unit = "autosize";
[@bs.module "autosize"]
external autosizeDestroy: Dom.element => unit = "destroy";

let withElement = (action, id) =>
  switch (document |> Document.getElementById(id)) {
  | Some(element) => action(element)
  | None => ()
  };

let create = id => id |> withElement(element => element |> autosize);
let destroy = id => id |> withElement(element => element |> autosizeDestroy);

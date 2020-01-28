[@bs.config {jsx: 3}];

let str = React.string;

module Autosize = {
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
};

[@react.component]
let make = (~value, ~onChange) => {
  let (id, _) = React.useState(() => DateTime.randomId());

  React.useEffect0(() => {
    Autosize.create(id);
    Some(() => Autosize.destroy(id));
  });

  <textarea onChange id value className="w-full h-full border p-2" />;
};

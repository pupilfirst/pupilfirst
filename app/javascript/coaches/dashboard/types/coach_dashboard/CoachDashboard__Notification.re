type pNotify;

[@bs.module "pnotify/dist/es/PNotify"] external pNotify: pNotify = "default";

[@bs.send] external success: (pNotify, Js.Json.t) => unit = "success";

[@bs.send] external error: (pNotify, Js.Json.t) => unit = "error";

/* TODO: Combine into single external 'alert' with the type field set if required. */
let success = (title, text) =>
  Json.Encode.(
    object_([
      ("title", title |> string),
      ("text", text |> string),
      ("styling", "bootstrap4" |> string),
      ("delay", 4000 |> int),
    ])
  )
  |> success(pNotify);

let error = (title, text) =>
  Json.Encode.(
    object_([
      ("title", title |> string),
      ("text", text |> string),
      ("styling", "bootstrap4" |> string),
      ("delay", 4000 |> int),
    ])
  )
  |> error(pNotify);

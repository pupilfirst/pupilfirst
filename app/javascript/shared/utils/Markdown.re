type options = Js.Json.t;

[@bs.module] external jsParse: (string, options) => string = "marked";

let parse = (markdown, ~sanitize=true, ()) =>
  jsParse(markdown, Json.Encode.(object_([("sanitize", bool(sanitize))])));
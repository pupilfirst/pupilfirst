type t = {
  id: int,
  value: string,
  hint: option(string),
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    value: json |> field("value", string),
    hint: json |> field("hint", nullable(string)) |> Js.Null.toOption,
  };

let id = t => t.id;

let value = t => t.value;

let hint = t => t.hint;
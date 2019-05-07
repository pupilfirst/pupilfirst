type t = {
  title: string,
  url: option(string),
  methord: option(string),
  options: t,
};

let decode = json =>
  Json.Decode.{
    title: json |> field("value", string),
    url: json |> field("url", nullable(string)) |> Js.Null.toOption,
    methord: json |> field("url", nullable(string)) |> Js.Null.toOption,
  };

let id = t => t.id;

let value = t => t.value;

let hint = t => t.hint;
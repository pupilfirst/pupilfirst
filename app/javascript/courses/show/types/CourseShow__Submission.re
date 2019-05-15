type t = {
  targetId: string,
  passedAt: option(string),
};

let decode = json =>
  Json.Decode.{
    targetId: json |> field("targetId", string),
    passedAt:
      json |> field("passedAt", nullable(string)) |> Js.Null.toOption,
  };
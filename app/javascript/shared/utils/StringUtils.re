let parameterize = t =>
  t
  |> Js.String.toLowerCase
  |> Js.String.replaceByRe([%re "/[^0-9a-zA-Z]+/gi"], "-")
  |> Js.String.replaceByRe([%re "/^-|-$/gmi"], "");

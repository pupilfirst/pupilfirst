let parameterize = t =>
  t
  |> Js.String.toLowerCase
  |> Js.String.replaceByRe([%re "/[^0-9a-zA-Z]+/gi"], "-")
  |> Js.String.replaceByRe([%re "/^-|-$/gmi"], "");

let paramToId = param => {
  [%re "/^\\d+/g"]
  ->Js.Re.exec_(param)
  ->Belt.Option.map(Js.Re.captures)
  ->Belt.Option.map(Js.Array.joinWith(""));
};

let includes = (~caseInsensitive=true, source, target) => {
  let (finalSource, finalTarget) =
    if (caseInsensitive) {
      (
        Js.String.toLocaleLowerCase(source),
        Js.String.toLocaleLowerCase(target),
      );
    } else {
      (source, target);
    };

  Js.String.includes(finalSource, finalTarget);
};

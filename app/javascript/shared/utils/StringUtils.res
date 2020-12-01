let parameterize = t =>
  t
  |> Js.String.toLowerCase
  |> Js.String.replaceByRe(%re("/[^0-9a-zA-Z]+/gi"), "-")
  |> Js.String.replaceByRe(%re("/^-|-$/gmi"), "")

let paramToId = param =>
  %re("/^\\d+/g")
  ->Js.Re.exec_(param)
  ->Belt.Option.map(Js.Re.captures)
  ->Belt.Option.map(Js.Array.joinWith(""))

let includes = (~caseInsensitive=true, source, target) => {
  let (finalSource, finalTarget) = if caseInsensitive {
    (Js.String.toLocaleLowerCase(source), Js.String.toLocaleLowerCase(target))
  } else {
    (source, target)
  }

  Js.String.includes(finalSource, finalTarget)
}

let isPresent = t => Js.String.trim(t) != ""

let colors = [
  ("#ff4040", false),
  ("#7f2020", false),
  ("#cc5c33", false),
  ("#734939", false),
  ("#bf9c8f", false),
  ("#995200", false),
  ("#4c2900", false),
  ("#f2a200", false),
  ("#ffd580", true),
  ("#332b1a", false),
  ("#4c3d00", false),
  ("#ffee00", true),
  ("#b0b386", false),
  ("#64664d", false),
  ("#6c8020", false),
  ("#c3d96c", true),
  ("#143300", false),
  ("#19bf00", false),
  ("#53a669", false),
  ("#bfffd9", true),
  ("#40ffbf", true),
  ("#1a332e", false),
  ("#00b3a7", false),
  ("#165955", false),
  ("#00b8e6", false),
  ("#69818c", false),
  ("#005ce6", false),
  ("#6086bf", false),
  ("#000e66", false),
  ("#202440", false),
  ("#393973", false),
  ("#4700b3", false),
  ("#2b0d33", false),
  ("#aa86b3", false),
  ("#ee00ff", false),
  ("#bf60b9", false),
  ("#4d3949", false),
  ("#ff00aa", false),
  ("#7f0044", false),
  ("#f20061", false),
  ("#330007", false),
  ("#d96c7b", false),
]

let stringToInt = name => {
  let rec aux = (sum, remains) =>
    switch remains {
    | "" => sum
    | remains =>
      let firstCharacter = remains |> Js.String.slice(~from=0, ~to_=1)
      let remains = remains |> Js.String.sliceToEnd(~from=1)
      aux(sum +. (firstCharacter |> Js.String.charCodeAt(0)), remains)
    }

  aux(0.0, name) |> int_of_float
}

let toColor = t => {
  let index = mod(t |> stringToInt, 42)
  let (backgroundColor, blackText) = colors[index]
  (backgroundColor, blackText ? "#000000" : "#FFFFFF")
}

let ts = I18n.t(~scope="shared.level")

let format = (~short: bool=false, ~name=?, number) => {
  let prefix = switch short {
    | true  => ts("short_label")
    | false => ts("label") ++ " "
  }
  let formattedName = switch name {
    | Some(value) => ": " ++ value
    | None        => ""
  }

  prefix ++ number ++ formattedName
}

let searchString = (number, name) => {
  (ts("label") |> Js.String.toLowerCase) ++ " " ++ number ++ " " ++ name
}

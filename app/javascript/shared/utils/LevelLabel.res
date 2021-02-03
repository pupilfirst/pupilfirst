let ts = I18n.t(~scope="shared.level_label")

let format = (~short: false, ~name=?, number) => {
  let prefix = switch short {
  | true => ts("short")
  | false => ts("long") ++ " "
  }
  let formattedName = switch name {
  | Some(value) => ": " ++ value
  | None => ""
  }

  prefix ++ number ++ formattedName
}

let searchString = (number, name) => {
  (ts("long") |> Js.String.toLowerCase) ++ " " ++ number ++ " " ++ name
}

let ts = I18n.t(~scope="shared.level_label")

let format = (~short=false, ~name=?, number) => {
  switch name {
  | Some(name) =>
    short
      ? ts(~variables=[("number", number), ("name", name)], "short_with_name")
      : ts(~variables=[("number", number), ("name", name)], "long_with_name")
  | None =>
    short
      ? ts(~variables=[("number", number)], "short_without_name")
      : ts(~variables=[("number", number)], "long_without_name")
  }
}

let searchString = (number, name) => {
  (ts("long") |> Js.String.toLowerCase) ++ " " ++ number ++ " " ++ name
}

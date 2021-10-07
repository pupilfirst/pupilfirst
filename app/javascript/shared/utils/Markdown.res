@module("./markdownIt") external markdownIt: string => string = "default"

type profile =
  | Permissive
  | AreaOfText

let profileString = profile =>
  switch profile {
  | Permissive => "permissive"
  | AreaOfText => "areaOfText"
  }

let parse = (_profile, markdown) => markdown |> markdownIt

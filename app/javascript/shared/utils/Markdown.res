@bs.module("./markdownIt") external markdownIt: string => string = "default"

type profile =
  | QuestionAndAnswer
  | Permissive
  | AreaOfText

let profileString = profile =>
  switch profile {
  | QuestionAndAnswer => "questionAndAnswer"
  | Permissive => "permissive"
  | AreaOfText => "areaOfText"
  }

let parse = (_profile, markdown) => markdown |> markdownIt

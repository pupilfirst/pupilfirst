type t = {
  id: string,
  title: string,
  milestoneNumber: int,
  completed: bool,
}

let id = t => t.id

let title = t => t.title

let completed = t => t.completed

let milestoneNumber = t => t.milestoneNumber

let make = (~id, ~title, ~completed, ~milestoneNumber) => {
  id: id,
  title: title,
  completed: completed,
  milestoneNumber: milestoneNumber,
}

let makeFromJs = data => {
  data->Js.Array2.map(data =>
    make(
      ~id=data["id"],
      ~title=data["title"],
      ~completed=data["completed"],
      ~milestoneNumber=data["milestoneNumber"],
    )
  )
}

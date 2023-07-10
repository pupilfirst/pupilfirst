type t = {
  id: string,
  title: string,
  milestoneNumber: int,
}

let id = t => t.id
let title = t => t.title
let milestoneNumber = t => t.milestoneNumber

let make = (~id, ~title, ~milestoneNumber) => {
  id: id,
  title: title,
  milestoneNumber: milestoneNumber,
}

let makeFromJs = target => {
  make(~id=target["id"], ~title=target["title"], ~milestoneNumber=target["milestoneNumber"])
}

type t = {
  id: string,
  title: string,
  milestoneNumber: option<int>,
}

let id = t => t.id

let title = t =>
  switch t.milestoneNumber {
  | None => t.title
  | Some(milestoneNumber) =>
    I18n.t("shared.m") ++ string_of_int(milestoneNumber) ++ " - " ++ t.title
  }

let milestoneNumber = t => t.milestoneNumber

let make = (~id, ~title, ~milestoneNumber) => {
  id: id,
  title: title,
  milestoneNumber: milestoneNumber,
}

let makeFromJs = target => {
  make(~id=target["id"], ~title=target["title"], ~milestoneNumber=target["milestoneNumber"])
}

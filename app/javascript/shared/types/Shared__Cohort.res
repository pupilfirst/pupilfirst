type t = {
  id: string,
  name: string,
  description: option<string>,
  endsAt: option<Js.Date.t>,
}

let make = (~id, ~name, ~description, ~endsAt) => {
  id: id,
  name: name,
  description: description,
  endsAt: endsAt,
}

let id = t => t.id
let name = t => t.name
let description = t => t.description
let endsAt = t => t.endsAt

let makeFromJs = cohort => {
  make(
    ~id=cohort["id"],
    ~name=cohort["name"],
    ~description=cohort["description"],
    ~endsAt=cohort["endsAt"]->Belt.Option.map(DateFns.decodeISO),
  )
}

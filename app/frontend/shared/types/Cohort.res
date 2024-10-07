type t = {
  id: string,
  name: string,
  description: option<string>,
  endsAt: option<Js.Date.t>,
  courseId: string,
}

let make = (~id, ~name, ~description, ~endsAt, ~courseId) => {
  id,
  name,
  description,
  endsAt,
  courseId,
}

let id = t => t.id
let name = t => t.name
let description = t => t.description
let endsAt = t => t.endsAt
let courseId = t => t.courseId

let decode = json =>
  switch json {
  | JsonUtils.Object(dict) =>
    let endsAt = JsonUtils.parseTimestamp(dict, "endsAt", "Cohort.decode")

    make(
      ~id=dict->Dict.getUnsafe("id"),
      ~name=dict->Dict.getUnsafe("name"),
      ~description=dict->Dict.getUnsafe("description"),
      ~courseId=dict->Dict.getUnsafe("courseId"),
      ~endsAt,
    )
  | _ => raise(JsonUtils.DecodeError("Invalid JSON supplied to Cohort.decode"))
  }

let filterValue = t => t.id ++ ";" ++ t.name

module Fragment = %graphql(`
  fragment CohortFragment on Cohort {
    id
    name
    description
    endsAt
    courseId
  }
`)

let makeFromFragment = (cohort: Fragment.t) => {
  make(
    ~id=cohort.id,
    ~name=cohort.name,
    ~description=cohort.description,
    ~endsAt=cohort.endsAt->Belt.Option.map(DateFns.decodeISO),
    ~courseId=cohort.courseId,
  )
}

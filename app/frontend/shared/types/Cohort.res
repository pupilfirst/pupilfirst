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
  | JsonUtils.Object(dict) => {
      let description = switch dict->Dict.get("description") {
      | Some(String(description)) => Some(description)
      | Some(JsonUtils.Null) => None
      | _ =>
        raise(JsonUtils.DecodeError("Unexpected value for description supplied to Cohort.decode"))
      }

      let endsAt = switch dict->Dict.get("endsAt") {
      | Some(String(endsAtString)) => DateFns.parseISO(endsAtString)->Some
      | Some(JsonUtils.Null) => None
      | _ => raise(JsonUtils.DecodeError("Unexpected value for endsAt supplied to Cohort.decode"))
      }

      switch (dict->Dict.get("id"), dict->Dict.get("name"), dict->Dict.get("courseId")) {
      | (Some(String(id)), Some(String(name)), Some(String(courseId))) => make(
          ~id,
          ~name,
          ~description,
          ~endsAt,
          ~courseId,
        )
      | _ =>
        raise(
          JsonUtils.DecodeError(
            "JSON supplied to Cohort.decode did not contain valid id, name, or courseId",
          ),
        )
      }
    }
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

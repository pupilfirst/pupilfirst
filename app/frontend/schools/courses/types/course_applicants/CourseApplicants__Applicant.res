type t = {
  id: string,
  name: string,
  email: string,
  tags: array<string>,
}

let name = t => t.name

let tags = t => t.tags

let id = t => t.id

let email = t => t.email

let make = (~id, ~name, ~tags, ~email) => {
  id,
  name,
  tags,
  email,
}

let makeFromJS = applicantDetails =>
  make(
    ~id=applicantDetails["id"],
    ~name=applicantDetails["name"],
    ~tags=applicantDetails["tags"],
    ~email=applicantDetails["email"],
  )

module Decode = {
  open Json.Decode

  let applicant = object(field => {
    id: field.required("id", string),
    name: field.required("name", string),
    email: field.required("email", string),
    tags: field.required("tags", array(string)),
  })
}

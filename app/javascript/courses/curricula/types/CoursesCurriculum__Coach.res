type t = {
  id: string,
  userId: string,
  coachingSessionCalendlyLink: option<string>,
}

let id = t => t.id
let userId = t => t.userId
let coachingSessionCalendlyLink = t => t.coachingSessionCalendlyLink

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    userId: json |> field("userId", string),
    coachingSessionCalendlyLink: json |> optional(field("coachingSessionCalendlyLink", string))
  }
}

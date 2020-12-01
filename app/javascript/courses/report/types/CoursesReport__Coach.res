type t = {
  name: string,
  title: string,
  avatarUrl: option<string>,
  coachingSessionCalendlyLink: option<string>
}

let name = t => t.name

let title = t => t.title

let avatarUrl = t => t.avatarUrl

let coachingSessionCalendlyLink = t => t.coachingSessionCalendlyLink

let decode = json => {
  open Json.Decode
  {
    name: json |> field("name", string),
    title: json |> field("title", string),
    avatarUrl: json |> field("avatarUrl", optional(string)),
    coachingSessionCalendlyLink: json |> field("coachingSessionCalendlyLink", optional(string))
  }
}

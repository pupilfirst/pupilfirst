type t = {
  name: string,
  email: string,
  title: string,
  affiliation: string,
}

let name = t => t.name

let email = t => t.email

let title = t => t.title

let affiliation = t => t.affiliation

let encode = (~teamName, ~tags, t) => {
  open Json.Encode
  object_(list{
    ("team_name", teamName |> string),
    ("tags", tags |> array(string)),
    ("name", t.name |> string),
    ("email", t.email |> string),
    ("title", t.title |> string),
    ("affiliation", t.affiliation |> string),
  })
}

let make = (~name, ~email, ~title, ~affiliation) => {
  name: name,
  email: email,
  title: title,
  affiliation: affiliation,
}

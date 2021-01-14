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

let toJsObject = (~teamName, ~tags, t) => {
  {
    "name": t.name,
    "email": t.email,
    "title": Some(t.title),
    "affiliation": Some(t.affiliation),
    "teamName": Some(teamName),
    "tags": tags,
  }
}

let make = (~name, ~email, ~title, ~affiliation) => {
  name: name,
  email: email,
  title: title,
  affiliation: affiliation,
}

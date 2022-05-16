type t = {
  name: string,
  email: string,
  title: string,
  affiliation: string,
  cohortId: string,
}

let name = t => t.name

let email = t => t.email

let title = t => t.title

let affiliation = t => t.affiliation

let cohortId = t => t.cohortId

let toJsObject = (~teamName, ~tags, t) => {
  {
    "name": t.name,
    "email": t.email,
    "title": Some(t.title),
    "affiliation": Some(t.affiliation),
    "teamName": Some(teamName),
    "tags": tags,
    "cohortId": t.cohortId,
  }
}

let make = (~name, ~email, ~title, ~affiliation, ~cohortId) => {
  name: name,
  email: email,
  title: title,
  affiliation: affiliation,
  cohortId: cohortId,
}

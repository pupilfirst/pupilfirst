type t = {
  name: option<string>,
  email: option<string>,
  tags: option<string>,
  title: option<string>,
  team_name: option<string>,
  affiliation: option<string>,
}

let name = t => t.name

let email = t => t.email

let tags = t => t.tags

let title = t => t.title

let teamName = t => t.team_name

let affiliation = t => t.affiliation

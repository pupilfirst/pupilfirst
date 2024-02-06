type t = {
  id: string,
  name: string,
  title: string,
  affiliation: option<string>,
  fullTitle: string,
  avatarUrl: option<string>,
  taggings: array<string>,
  lastSeenAt: option<Js.Date.t>,
  currentStandingName: option<string>,
}

let id = t => t.id
let name = t => t.name
let avatarUrl = t => t.avatarUrl
let fullTitle = t => t.fullTitle
let lastSeenAt = t => t.lastSeenAt
let taggings = t => t.taggings
let affiliation = t => t.affiliation
let title = t => t.title
let currentStandingName = t => t.currentStandingName
module Fragment = %graphql(`
  fragment UserDetailsFragment on User {
    id
    name
    title
    affiliation
    fullTitle
    avatarUrl
    taggings
    lastSeenAt
    currentStandingName
  }
`)

let makeFromFragment = (user: Fragment.t) => {
  id: user.id,
  name: user.name,
  title: user.title,
  affiliation: user.affiliation,
  fullTitle: user.fullTitle,
  avatarUrl: user.avatarUrl,
  taggings: user.taggings,
  lastSeenAt: user.lastSeenAt->Belt.Option.map(DateFns.decodeISO),
  currentStandingName: user.currentStandingName,
}

let makeFromJs = jsObject => {
  id: jsObject["id"],
  name: jsObject["name"],
  avatarUrl: jsObject["avatarUrl"],
  fullTitle: jsObject["fullTitle"],
  taggings: jsObject["taggings"],
  lastSeenAt: jsObject["lastSeenAt"]->Belt.Option.map(DateFns.decodeISO),
  title: jsObject["title"],
  affiliation: jsObject["affiliation"],
  currentStandingName: jsObject["currentStandingName"],
}

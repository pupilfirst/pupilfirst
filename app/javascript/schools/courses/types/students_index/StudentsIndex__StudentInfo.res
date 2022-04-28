type t = {
  id: string,
  name: string,
  title: string,
  affiliation: option<string>,
  avatarUrl: option<string>,
  taggings: array<string>,
  userTags: array<string>,
  level: Shared__Level.t,
  cohort: Shared__Cohort.t,
}

let id = t => t.id
let name = t => t.name
let title = t => t.title
let affiliation = t => t.affiliation
let avatarUrl = t => t.avatarUrl
let taggings = t => t.taggings
let userTags = t => t.userTags
let level = t => t.level
let cohort = t => t.cohort

let make = (
  ~id,
  ~name,
  ~title,
  ~affiliation,
  ~avatarUrl,
  ~taggings,
  ~userTags,
  ~level,
  ~cohort,
) => {
  id: id,
  name: name,
  title: title,
  affiliation: affiliation,
  avatarUrl: avatarUrl,
  taggings: taggings,
  userTags: userTags,
  level: level,
  cohort: cohort,
}

let makeFromJS = studentDetails =>
  make(
    ~id=studentDetails["id"],
    ~name=studentDetails["name"],
    ~title=studentDetails["title"],
    ~affiliation=studentDetails["affiliation"],
    ~avatarUrl=studentDetails["avatarUrl"],
    ~taggings=studentDetails["taggings"],
    ~userTags=studentDetails["userTags"],
    ~level=Shared__Level.makeFromJs(studentDetails["level"]),
    ~cohort=Shared__Cohort.makeFromJs(studentDetails["cohort"]),
  )

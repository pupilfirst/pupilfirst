type t = {
  id: string,
  name: string,
  title: string,
  affiliation: option<string>,
  avatarUrl: option<string>,
  taggings: array<string>,
  userTags: array<string>,
  levelId: string,
}

let id = t => t.id
let name = t => t.name
let title = t => t.title
let affiliation = t => t.affiliation
let avatarUrl = t => t.avatarUrl
let taggings = t => t.taggings
let userTags = t => t.userTags
let levelId = t => t.levelId

let make = (
  ~id,
  ~name,
  ~title,
  ~affiliation,
  ~avatarUrl,
  ~taggings,
  ~userTags,
  ~levelId,
) => {
  id: id,
  name: name,
  title: title,
  affiliation: affiliation,
  avatarUrl: avatarUrl,
  taggings: taggings,
  userTags: userTags,
  levelId: levelId,
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
    ~levelId=studentDetails["levelId"],
  )

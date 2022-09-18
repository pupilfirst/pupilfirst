type community = {
  communityName: string,
  communityId: string,
}

type t = {
  id: string,
  name: string,
  canReview: bool,
  isAuthor: bool,
  enableLeaderboard: bool,
  description: string,
  exited: bool,
  thumbnailUrl: option<string>,
  linkedCommunities: array<community>,
  ended: bool,
  isStudent: bool,
}

let name = t => t.name
let id = t => t.id
let canReview = t => t.canReview
let isAuthor = t => t.isAuthor
let description = t => t.description
let exited = t => t.exited
let thumbnailUrl = t => t.thumbnailUrl
let linkedCommunities = t => t.linkedCommunities
let ended = t => t.ended
let enableLeaderboard = t => t.enableLeaderboard
let isStudent = t => t.isStudent

let decodeCommunity = json => {
  open Json.Decode
  {
    communityId: field("id", string, json),
    communityName: field("name", string, json),
  }
}

let decode = json => {
  open Json.Decode
  {
    id: field("id", string, json),
    name: field("name", string, json),
    description: field("description", string, json),
    exited: field("exited", bool, json),
    canReview: field("canReview", bool, json),
    isAuthor: field("isAuthor", bool, json),
    enableLeaderboard: field("enableLeaderboard", bool, json),
    thumbnailUrl: field("thumbnailUrl", nullable(string), json)->Js.Null.toOption,
    linkedCommunities: field("linkedCommunities", array(decodeCommunity), json),
    ended: field("ended", bool, json),
    isStudent: field("isStudent", bool, json),
  }
}

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

module Decode = {
  open Json.Decode

  let community = object(field => {
    communityId: field.required("id", string),
    communityName: field.required("name", string),
  })

  let course = object(field => {
    id: field.required("id", string),
    name: field.required("name", string),
    description: field.required("description", string),
    exited: field.required("exited", bool),
    canReview: field.required("canReview", bool),
    isAuthor: field.required("isAuthor", bool),
    enableLeaderboard: field.required("enableLeaderboard", bool),
    thumbnailUrl: field.optional("thumbnailUrl", option(string))->OptionUtils.flat,
    linkedCommunities: field.required("linkedCommunities", array(community)),
    ended: field.required("ended", bool),
    isStudent: field.required("isStudent", bool),
  })
}

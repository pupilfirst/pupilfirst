type t = {
  id: string,
  userId: string,
  name: string,
  avatarUrl: option<string>,
  fullTitle: string,
}

let id = t => t.id
let userId = t => t.userId
let name = t => t.name
let avatarUrl = t => t.avatarUrl
let fullTitle = t => t.fullTitle

let decode = json => {
  open Json.Decode
  {
    id: field("id", string, json),
    userId: field("userId", string, json),
    name: field("name", string, json),
    avatarUrl: option(field("avatarUrl", string), json),
    fullTitle: field("fullTitle", string, json),
  }
}

let findById = (id, proxies) =>
  ListUtils.unsafeFind(
    proxy => proxy.id == id,
    "Unable to find a UserProxy with ID " ++ id,
    proxies,
  )

let make = (~id, ~userId, ~name, ~avatarUrl, ~fullTitle) => {
  id,
  userId,
  name,
  avatarUrl,
  fullTitle,
}

let makeFromJs = jsObject =>
  make(
    ~id=jsObject["id"],
    ~userId=jsObject["userId"],
    ~name=jsObject["name"],
    ~avatarUrl=jsObject["avatarUrl"],
    ~fullTitle=jsObject["fullTitle"],
  )

module Fragment = %graphql(`
  fragment UserProxyFragment on UserProxy {
    id
    name
    userId
    fullTitle
    avatarUrl
  }
`)

let makeFromFragment = (user: Fragment.t) =>
  make(
    ~id=user.id,
    ~userId=user.userId,
    ~name=user.name,
    ~avatarUrl=user.avatarUrl,
    ~fullTitle=user.fullTitle,
  )

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
    id: json |> field("id", string),
    userId: json |> field("userId", string),
    name: json |> field("name", string),
    avatarUrl: json |> optional(field("avatarUrl", string)),
    fullTitle: json |> field("fullTitle", string),
  }
}

let findById = (id, proxies) =>
  proxies |> ListUtils.unsafeFind(
    proxy => proxy.id == id,
    "Unable to find a UserProxy with ID " ++ id,
  )

let make = (~id, ~userId, ~name, ~avatarUrl, ~fullTitle) => {
  id: id,
  userId: userId,
  name: name,
  avatarUrl: avatarUrl,
  fullTitle: fullTitle,
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

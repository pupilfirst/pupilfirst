type t = {
  id: string,
  name: string,
  avatarUrl: option<string>,
  fullTitle: string,
}

let id = t => t.id
let name = t => t.name
let avatarUrl = t => t.avatarUrl
let fullTitle = t => t.fullTitle

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    name: json |> field("name", string),
    avatarUrl: json |> optional(field("avatarUrl", string)),
    fullTitle: json |> field("fullTitle", string),
  }
}

let findById = (id, proxies) =>
  proxies |> ArrayUtils.unsafeFind(proxy => proxy.id == id, "Unable to find a User with ID " ++ id)

let make = (~id, ~name, ~avatarUrl, ~fullTitle) => {
  id: id,
  name: name,
  avatarUrl: avatarUrl,
  fullTitle: fullTitle,
}

let makeFromJs = jsObject =>
  make(
    ~id=jsObject["id"],
    ~name=jsObject["name"],
    ~avatarUrl=jsObject["avatarUrl"],
    ~fullTitle=jsObject["fullTitle"],
  )

module Fragment = %graphql(`
  fragment UserFragment on User {
    id
    name
    fullTitle
    avatarUrl
  }
`)

let makeFromFragment = (user: Fragment.t) =>
  make(~id=user.id, ~name=user.name, ~avatarUrl=user.avatarUrl, ~fullTitle=user.fullTitle)

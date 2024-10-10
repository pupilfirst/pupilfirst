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

module Decode = {
  open Json.Decode

  let decode = object(field => {
    id: field.required("id", string),
    name: field.required("name", string),
    avatarUrl: field.optional("avatarUrl", option(string))->Option.flatMap(x => x),
    fullTitle: field.required("fullTitle", string),
  })
}

let findById = (id, proxies) =>
  ArrayUtils.unsafeFind(proxy => proxy.id == id, "Unable to find a User with ID " ++ id, proxies)

let make = (~id, ~name, ~avatarUrl, ~fullTitle) => {
  id,
  name,
  avatarUrl,
  fullTitle,
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

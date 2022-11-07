type t = {
  title: string,
  url: string,
  local: bool,
}

let title = t => t.title

let url = t => t.url

let local = t => t.local

let decode = json => {
  open Json.Decode
  {
    title: field("title", string, json),
    url: field("url", string, json),
    local: field("local", bool, json),
  }
}

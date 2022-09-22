@module("./markdownIt") external parse: string => string = "default"

type profile =
  | Permissive
  | AreaOfText

let sanitize = (html, profile) => {
  switch profile {
  | Permissive =>
    DOMPurify.makeOptions(~addTags=["iframe"], ())->DOMPurify.sanitizedHTMLOpt(html, _)
  | AreaOfText =>
    DOMPurify.makeOptions(
      ~allowedTags=["p", "em", "strong", "del", "s", "a", "sup", "sub"],
      (),
    )->DOMPurify.sanitizedHTMLOpt(html, _)
  }
}

let toSafeHTML = (markdown, profile) => parse(markdown)->sanitize(profile)

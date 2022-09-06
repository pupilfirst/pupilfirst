@module("./markdownIt") external parse: string => string = "default"

type profile =
  | Permissive
  | AreaOfText

let sanitize = (html, profile) => {
  switch profile {
  | Permissive =>
    DOMPurify.sanitizedHTMLOpt(html, DOMPurify.makeOptions(~addTags=["iframe"], ()))
  | AreaOfText =>
    DOMPurify.sanitizedHTMLOpt(
      html,
      DOMPurify.makeOptions(
        ~allowedTags=["p", "em", "strong", "del", "s", "a", "sup", "sub"],
        (),
      ),
    )
  }
}

let toSafeHTML = (markdown, profile) => parse(markdown)->sanitize(profile)

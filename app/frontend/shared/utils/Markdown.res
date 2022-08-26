@module("./markdownIt") external parse: string => string = "default"

type profile =
  | Permissive
  | AreaOfText

let sanitize = (html, profile) => {
  switch profile {
  | Permissive =>
    DOMPurify.sanitizedHTMLOpt(html, DOMPurify.getOptions(~addTags=Some(["iframe"]), ()))
  | AreaOfText =>
    DOMPurify.sanitizedHTMLOpt(
      html,
      DOMPurify.getOptions(
        ~allowedTags=Some(["p", "em", "strong", "del", "s", "a", "sup", "sub"]),
        (),
      ),
    )
  }
}

let toSafeHTML = (markdown, profile) => parse(markdown)->sanitize(profile)

@module("./markdownIt") external parse: string => string = "default"

type profile =
  | Permissive
  | AreaOfText

let sanitize = (html, profile) => {
  switch profile {
  | Permissive => DOMPurify.sanitizedHTML(html)
  | AreaOfText =>
    DOMPurify.sanitizedHTMLOpt(
      html,
      {
        "ALLOWED_TAGS": ["p", "em", "strong", "del", "s", "a", "sup", "sub"],
      },
    )
  }
}

let toSafeHTML = (markdown, profile) => parse(markdown)->sanitize(profile)

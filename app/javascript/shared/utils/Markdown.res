@module("./markdownIt") external parse: string => string = "default"

type profile =
  | Permissive
  | AreaOfText

let sanitize = (html, profile) => {
  switch profile {
  | Permissive =>
    DOMPurify.sanitizedHTML(
      html,
      {
        "ADD_ATTR": ["target"],
      },
    )
  | AreaOfText =>
    DOMPurify.sanitizedHTMLOpt(
      html,
      {
        "ALLOWED_TAGS": ["p", "em", "strong", "del", "s", "a", "sup", "sub"],
        "ADD_ATTR": ["target"],
      },
    )
  }
}

let toSafeHTML = (markdown, profile) => parse(markdown)->sanitize(profile)

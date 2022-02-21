type options = {"ALLOWED_TAGS": array<string>, "ADD_ATTR": array<string>}
type optionsTwo = {"ADD_ATTR": array<string>}

@module("dompurify") external sanitize: string => string = "sanitize"
@module("dompurify") external sanitizeHTML: (string, optionsTwo) => string = "sanitize"
@module("dompurify") external sanitizeOpt: (string, options) => string = "sanitize"

let sanitizedHTML = (html, optionsTwo) => {"__html": sanitizeHTML(html, optionsTwo)}

let sanitizedHTMLOpt = (html, options) => {"__html": sanitizeOpt(html, options)}

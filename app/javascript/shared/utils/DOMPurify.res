type options = {"ALLOWED_TAGS": array<string>, "ADD_ATTR": array<string>}

@module("dompurify") external sanitize: (string, options) => string = "sanitize"
@module("dompurify") external sanitizeOpt: (string, options) => string = "sanitize"

let sanitizedHTML = (html, options) => {"__html": sanitize(html, options)}

let sanitizedHTMLOpt = (html, options) => {"__html": sanitizeOpt(html, options)}

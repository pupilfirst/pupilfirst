@module("dompurify") external sanitize: string => string = "sanitize"

type options = {"ALLOWED_TAGS": array<string>}

@module("dompurify") external sanitizeOpt: (string, options) => string = "sanitize"

let sanitizedHTML = html => {"__html": sanitize(html)}

let sanitizedHTMLOpt = (html, options) => {"__html": sanitizeOpt(html, options)}

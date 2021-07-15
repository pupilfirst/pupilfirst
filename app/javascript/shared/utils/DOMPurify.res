@module("dompurify") external sanitize: string => string = "sanitize"

let sanitizedHTML = html => {"__html": sanitize(html)}

type dompurify

@module("dompurify") external dompurify: dompurify = "default"
@send external sanitizeExternal: (dompurify, string) => string = "sanitize"

let sanitize = s => sanitizeExternal(dompurify, s)

type options = Js.Dict.t<array<string>>

let makeOptions = (~addTags=[], ~allowedTags=[], ()) => {
  let opt = Js.Dict.empty()

  if ArrayUtils.isNotEmpty(addTags) {
    opt->Js.Dict.set("ADD_TAGS", addTags)
    opt->Js.Dict.set("ADD_ATTR", ["allowfullscreen", "webkitallowfullscreen", "mozallowfullscreen"])
  }

  if ArrayUtils.isNotEmpty(allowedTags) {
    opt->Js.Dict.set("ALLOWED_TAGS", allowedTags)
  }

  opt
}

@send external sanitizeOptExternal: (dompurify, string, options) => string = "sanitize"

let sanitizeOpt = (s, opt) => sanitizeOptExternal(dompurify, s, opt)

let sanitizedHTML = html => {"__html": sanitize(html)}

let sanitizedHTMLOpt = (html, options) => {
  {"__html": sanitizeOpt(html, options)}
}

@send external addHook: (dompurify, string, Dom.node => unit) => int = "addHook"

let sanitizedHTMLHook = (entryPoint, hookFunction) => {
  addHook(dompurify, entryPoint, hookFunction)
}

%%raw(`
  document.addEventListener(
    "DOMContentLoaded", () => {

      sanitizedHTMLHook('uponSanitizeElement', (node, data) => {
        if (data.tagName === 'iframe') {
          const src = node.getAttribute('src') || ''
          if (!(src.startsWith('https://www.youtube.com/embed/') ||
            src.startsWith('https://player.vimeo.com/video/'))
          ) {
            if (node.parentNode) {
              return node.parentNode.removeChild(node)
            }
          }
        }
      })

      sanitizedHTMLHook('afterSanitizeAttributes', function(node) {
          // set all elements owning target to target=_blank
          if ('target' in node) {
              node.setAttribute('target','_blank');
              // prevent https://www.owasp.org/index.php/Reverse_Tabnabbing
              node.setAttribute('rel', 'noopener noreferrer');
          }
          // set non-HTML/MathML links to xlink:show=new
          if (!node.hasAttribute('target')
              && (node.hasAttribute('xlink:href')
                  || node.hasAttribute('href'))) {
              node.setAttribute('xlink:show', 'new');
          }
      });
    },
    false
  );
`)

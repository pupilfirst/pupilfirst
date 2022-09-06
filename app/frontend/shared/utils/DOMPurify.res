type dompurify

@module("dompurify") external dompurify: dompurify = "default"
@send external sanitizeExternal: (dompurify, string) => string = "sanitize"

let sanitize = s => sanitizeExternal(dompurify, s)

type optionalStringArray = option<array<string>>

type options = Js.Dict.t<optionalStringArray>

let getOptions = (~addTags=?, ~allowedTags=?, ()): options => {
  let opt = Js.Dict.empty()
  switch addTags {
  | Some(tags) => opt->Js.Dict.set("ADD_TAGS", tags)
  | _ => ()
  }
  switch allowedTags {
  | Some(tags) => opt->Js.Dict.set("ALLOWED_TAGS", tags)
  | _ => ()
  }
  // Allow full screen in iframe
  opt->Js.Dict.set(
    "ADD_ATTR",
    Some(["allowfullscreen", "webkitallowfullscreen", "mozallowfullscreen"]),
  )
  opt
}

@send external sanitizeOptExternal: (dompurify, string, options) => string = "sanitize"

let sanitizeOpt = (s, opt) => sanitizeOptExternal(dompurify, s, opt)

let sanitizedHTML = html => {"__html": sanitize(html)}

let sanitizedHTMLOpt = (html, options) => {
  Js.log(options)
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
            console.log("removing",src)
            console.log(!src.startsWith('https://www.youtube.com/embed/'),
            !src.startsWith('https://player.vimeo.com/video/'))
            return node.parentNode?.removeChild(node)
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

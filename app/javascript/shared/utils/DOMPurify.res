@module("dompurify") external sanitize: string => string = "sanitize"

type options = {"ALLOWED_TAGS": array<string>}

@module("dompurify") external sanitizeOpt: (string, options) => string = "sanitize"

let sanitizedHTML = html => {"__html": sanitize(html)}

let sanitizedHTMLOpt = (html, options) => {"__html": sanitizeOpt(html, options)}

@module("dompurify") external addHook: (string, Dom.node => unit) => int = "addHook"

let sanitizedHTMLHook = (entryPoint, hookFunction) => {
  addHook(entryPoint, hookFunction)
}

%%raw(`
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
`)

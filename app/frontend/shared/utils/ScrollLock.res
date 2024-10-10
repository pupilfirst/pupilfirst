open Webapi.Dom

let handleScrollLock = add => {
  let classes = add ? "overflow-hidden" : ""

  let body = document->Document.getElementsByTagName("body")->HtmlCollection.toArray

  body[0]->Option.map(el => Element.setClassName(el, classes))->ignore
}

let activate = () => handleScrollLock(true)
let deactivate = () => handleScrollLock(false)

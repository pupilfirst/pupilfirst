open Webapi.Dom

@module("autosize") external autosizeFunction: Dom.element => unit = "default"

type autosize

@module("autosize") external autosizeModule: autosize = "default"

@send external autosizeDestroy: (autosize, Dom.element) => unit = "destroy"
@send external autosizeUpdate: (autosize, Dom.element) => unit = "update"

let perform = (f, id) =>
  OptionUtils.mapWithDefault(element => f(element), (), document->Document.getElementById(id))

let create = id => perform(autosizeFunction, id)
let update = id => perform(el => autosizeUpdate(autosizeModule, el), id)
let destroy = id => perform(el => autosizeDestroy(autosizeModule, el), id)

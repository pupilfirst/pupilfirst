open Webapi.Dom

@module("autosize") external autosizeFunction: Dom.element => unit = "default"

type autosize

@module("autosize") external autosizeModule: autosize = "default"

@send external autosizeDestroy: (autosize, Dom.element) => unit = "destroy"
@send external autosizeUpdate: (autosize, Dom.element) => unit = "update"

let perform = (f, id) =>
  document->Document.getElementById(id) |> OptionUtils.mapWithDefault(element => element |> f, ())

let create = id => id |> perform(autosizeFunction)
let update = id => id |> perform(autosizeUpdate(autosizeModule))
let destroy = id => id |> perform(autosizeDestroy(autosizeModule))

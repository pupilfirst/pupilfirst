module type CSVData = {
  type t
}

module Make = (CSVData: CSVData) => {
  module JsComponent = {
  @bs.module("./CSVReader") @react.component
  external make: (
    ~onFileLoaded: (Js.Array.t<CSVData.t>, Js.t<'b>) => unit,
    ~label: string=?,
    ~inputId: string=?,
    ~cssClass: string=?,
    ~inputStyle: string=?,
    ~onError: Js.t<string> => unit=?,
    ~parserOptions: Js.t<'a>,
  ) => React.element = "default"
}

external variablesToJsObject: Js.Dict.t<string> => Js.t<'a> = "%identity"

@react.component
let make = (
  ~onFileLoaded,
  ~cssClass=?,
  ~label=?,
  ~inputId=?,
  ~inputStyle=?,
  ~onError=?,
  ~parserOptions: array<(string, string)>=[],
) => {
  <JsComponent
    onFileLoaded
    ?label
    ?inputId
    ?cssClass
    ?inputStyle
    ?onError
    parserOptions={variablesToJsObject(Js.Dict.fromArray(parserOptions))}
  />
}
}

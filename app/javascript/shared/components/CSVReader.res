module JsComponent = {
  @bs.module("./CSVReader") @react.component
  external make: (~onFileLoaded: (Js.Array.t<string>, Js.t<'a>) => unit) => React.element =
    "default"
}

@react.component
let make = (~onFileLoaded) => {
  <JsComponent onFileLoaded />
}

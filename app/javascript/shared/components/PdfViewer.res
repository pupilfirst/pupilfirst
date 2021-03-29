module JsComponent = {
  @bs.module("./PdfViewer") @react.component
  external make: (
    ~id: string=?,
    ~url: string,
  ) => React.element = "default"
}

@react.component
let make = (~url, ~id=?) =>
  <JsComponent ?id url />

module type CSVData = {
  type t
}

module Make = (CSVData: CSVData) => {
  @deriving(abstract)
  type parserOptions = {
    @optional
    header: bool,
    @optional
    skipEmptyLines: string,
  }

  type fileInfo = {
    name: string,
    size: int,
    \"type": string,
  }

  let fileName = fileInfo => fileInfo.name

  let fileType = fileInfo => fileInfo.\"type"

  let fileSize = fileInfo => fileInfo.size

  module JsComponent = {
    @module("react-csv-reader") @react.component
    external make: (
      ~onFileLoaded: (Js.Array.t<CSVData.t>, fileInfo) => unit,
      ~label: string=?,
      ~inputId: string=?,
      ~inputName: string=?,
      ~cssClass: string=?,
      ~inputStyle: string=?,
      ~onError: string => unit=?,
      ~parserOptions: parserOptions,
    ) => React.element = "default"
  }

  @react.component
  let make = (
    ~onFileLoaded,
    ~cssClass=?,
    ~label=?,
    ~inputId=?,
    ~inputName=?,
    ~inputStyle=?,
    ~onError=?,
    ~parserOptions: parserOptions,
  ) => {
    <JsComponent
      onFileLoaded ?label ?inputId ?inputName ?cssClass ?inputStyle ?onError parserOptions
    />
  }
}

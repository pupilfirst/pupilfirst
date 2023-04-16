module type RowData = {
  type t
}

module Make = (RowData: RowData) => {
  type fileType = Dom.element

  type completionType = {"data": array<RowData.t>}

  @deriving(abstract)
  type config = {
    @optional
    delimiter: string,
    @optional
    newline: string,
    @optional
    quoteChar: string,
    @optional
    escapeChar: string,
    @optional
    header: bool,
    complete: (completionType, fileType) => unit,
  }

  @module("papaparse") external parseFile: (fileType, config) => unit = "parse"
}

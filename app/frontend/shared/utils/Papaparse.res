module type RowData = {
  type t
}

module Make = (RowData: RowData) => {
  type file = {"name": string, "size": int}

  type error = {
    @as("type") type_: string,
    code: string,
    message: string,
    row: int,
  }

  let errorMessage = error => error.message ++ " on row " ++ string_of_int(error.row)

  type results = {
    "data": array<RowData.t>,
    "errors": array<error>,
    "meta": {"fields": option<array<string>>},
  }

  @deriving(abstract)
  type config = {
    @optional
    header: bool,
    @optional
    skipEmptyLines: bool,
    complete: (results, file) => unit,
  }

  @module("papaparse") external parseFile: (file, config) => unit = "parse"
}

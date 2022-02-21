exception UnexpectedExportType(string)

type id = string

type file = {
  path: string,
  createdAt: Js.Date.t,
}

type exportType =
  | Teams
  | Students

type t = {
  id: id,
  tags: array<string>,
  createdAt: Js.Date.t,
  file: option<file>,
  reviewedOnly: bool,
  includeInactiveStudents: bool,
  exportType: exportType,
}

let id = t => t.id
let createdAt = (t: t) => t.createdAt
let tags = t => t.tags
let file = t => t.file
let exportType = t => t.exportType
let reviewedOnly = t => t.reviewedOnly
let includeInactiveStudents = t => t.includeInactiveStudents
let fileCreatedAt = (file: file) => file.createdAt
let filePath = file => file.path

let decodeFile = json => {
  open Json.Decode
  {
    path: json |> field("path", string),
    createdAt: json |> field("createdAt", DateFns.decodeISO),
  }
}

let decode = json => {
  open Json.Decode
  {
    id: json |> field("id", string),
    createdAt: json |> field("createdAt", DateFns.decodeISO),
    file: json |> field("file", nullable(decodeFile)) |> Js.Null.toOption,
    tags: json |> field("tags", array(string)),
    exportType: switch json |> field("exportType", string) {
    | "Students" => Students
    | "Teams" => Teams
    | otherExportType =>
      Rollbar.error("Unexpected exportType encountered: " ++ otherExportType)
      raise(UnexpectedExportType(otherExportType))
    },
    reviewedOnly: json |> field("reviewedOnly", bool),
    includeInactiveStudents: json |> field("includeInactiveStudents", bool),
  }
}

let make = (~id, ~exportType, ~createdAt, ~tags, ~reviewedOnly, ~includeInactiveStudents) => {
  id: id,
  createdAt: createdAt,
  tags: tags,
  exportType: exportType,
  reviewedOnly: reviewedOnly,
  includeInactiveStudents: includeInactiveStudents,
  file: None,
}

let exportTypeToString = t =>
  switch t.exportType {
  | Students => "Students"
  | Teams => "Teams"
  }

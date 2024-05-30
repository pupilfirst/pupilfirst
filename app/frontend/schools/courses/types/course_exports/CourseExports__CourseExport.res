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
  cohortIds: array<string>,
  includeUserStandings: bool,
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
let cohortIds = t => t.cohortIds
let includeUserStandings = t => t.includeUserStandings

let decodeFile = json => {
  open Json.Decode
  {
    path: field("path", string, json),
    createdAt: field("createdAt", DateFns.decodeISO, json),
  }
}

let decode = json => {
  open Json.Decode
  {
    id: field("id", string, json),
    createdAt: field("createdAt", DateFns.decodeISO, json),
    file: field("file", nullable(decodeFile), json)->Js.Null.toOption,
    tags: field("tags", array(string), json),
    exportType: switch field("exportType", string, json) {
    | "Students" => Students
    | "Teams" => Teams
    | otherExportType =>
      Rollbar.error("Unexpected exportType encountered: " ++ otherExportType)
      raise(UnexpectedExportType(otherExportType))
    },
    reviewedOnly: field("reviewedOnly", bool, json),
    includeInactiveStudents: field("includeInactiveStudents", bool, json),
    cohortIds: field("cohortIds", array(string), json),
    includeUserStandings: field("includeUserStandings", bool, json),
  }
}

let make = (
  ~id,
  ~exportType,
  ~createdAt,
  ~tags,
  ~reviewedOnly,
  ~includeInactiveStudents,
  ~cohortIds,
  ~includeUserStandings,
) => {
  id,
  createdAt,
  tags,
  exportType,
  reviewedOnly,
  includeInactiveStudents,
  file: None,
  cohortIds,
  includeUserStandings,
}

let exportTypeToString = t =>
  switch t.exportType {
  | Students => "Students"
  | Teams => "Teams"
  }

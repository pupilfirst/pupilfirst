exception UnexpectedExportType(string);

type id = string;

type file = {
  path: string,
  createdAt: string,
};

type exportType =
  | Teams
  | Students(tags)
and tags = array(string);

type t = {
  id,
  createdAt: string,
  file: option(file),
  reviewedOnly: bool,
  exportType,
};

let id = t => t.id;
let createdAt = (t: t) => t.createdAt;
let file = t => t.file;
let exportType = t => t.exportType;
let reviewedOnly = t => t.reviewedOnly;
let fileCreatedAt = (file: file) => file.createdAt;
let filePath = file => file.path;

let studentsWithoutTags = Students([||]);

let decodeFile = json =>
  Json.Decode.{
    path: json |> field("path", string),
    createdAt: json |> field("createdAt", string),
  };

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    createdAt: json |> field("createdAt", string),
    file: json |> field("file", nullable(decodeFile)) |> Js.Null.toOption,
    exportType:
      switch (json |> field("exportType", string)) {
      | "students" => Students(json |> field("tags", array(string)))
      | "teams" => Teams
      | otherExportType =>
        Rollbar.error(
          "Unexpected exportType encountered: " ++ otherExportType,
        );
        raise(UnexpectedExportType(otherExportType));
      },
    reviewedOnly: json |> field("reviewedOnly", bool),
  };

let makeStudentsExport = (~id, ~createdAt, ~tags, ~reviewedOnly) => {
  id,
  createdAt,
  exportType: Students(tags),
  reviewedOnly,
  file: None,
};

let makeTeamsExport = (~id, ~createdAt, ~reviewedOnly) => {
  id,
  createdAt,
  reviewedOnly,
  file: None,
  exportType: Teams,
};

exception UnexpectedStatusValue(string);

type status =
  | MarkedAsComplete
  | Pending
  | Passed
  | Failed;

type t = {
  id: string,
  description: string,
  createdAt: string,
  status,
};

let id = t => t.id;
let description = t => t.description;
let createdAt = t => t.createdAt;
let status = t => t.status;

let createdAtPretty = t =>
  t |> createdAt |> DateFns.parseString |> DateFns.format("MMMM D, YYYY");

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    description: json |> field("description", string),
    createdAt: json |> field("createdAt", string),
    status:
      switch (json |> field("status", string)) {
      | "marked_as_complete" => MarkedAsComplete
      | "pending" => Pending
      | "passed" => Passed
      | "failed" => Failed
      | unknownValue => raise(UnexpectedStatusValue(unknownValue))
      },
  };

let make = (~id, ~description, ~createdAt, ~status) => {
  id,
  description,
  createdAt,
  status,
};

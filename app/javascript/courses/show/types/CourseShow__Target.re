exception CannotParseUnknownRole(string);

type role =
  | Student
  | Team;

type t = {
  id: string,
  role,
  title: string,
  targetGroupId: string,
  sortIndex: int,
  resubmittable: bool,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    role:
      switch (json |> field("role", string)) {
      | "founder" => Student
      | "team" => Team
      | unknownRole => raise(CannotParseUnknownRole(unknownRole))
      },
    title: json |> field("title", string),
    targetGroupId: json |> field("targetGroupId", string),
    sortIndex: json |> field("sortIndex", int),
    resubmittable: json |> field("resubmittable", bool),
  };
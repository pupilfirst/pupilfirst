type t = {
  id: int,
  name: string,
  targets: list(CurriculumEditor__Target.t),
};

let name = t => t.name;

let targets = t => t.targets;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    name: json |> field("name", string),
    targets: json |> field("targets", list(CurriculumEditor__Target.decode)),
  };
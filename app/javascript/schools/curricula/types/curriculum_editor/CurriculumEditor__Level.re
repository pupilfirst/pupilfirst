type t = {
  id: int,
  name: string,
  targetGroups: list(CurriculumEditor__TargetGroup.t),
};

let name = t => t.name;

let id = t => t.id;

let targetGroups = t => t.targetGroups;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    name: json |> field("name", string),
    targetGroups:
      json
      |> field("targetGroups", list(CurriculumEditor__TargetGroup.decode)),
  };
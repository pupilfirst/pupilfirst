type t = {
  id: int,
  name: string,
  description: option(string),
  milestone: bool,
  levelId: int,
  sortIndex: int,
};

let id = t => t.id;

let name = t => t.name;

let description = t => t.description;

let milestone = t => t.milestone;

let levelId = t => t.levelId;

let sortIndex = t => t.sortIndex;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    name: json |> field("name", string),
    description:
      json |> field("description", nullable(string)) |> Js.Null.toOption,
    levelId: json |> field("levelId", int),
    milestone: json |> field("milestone", bool),
    sortIndex: json |> field("sortIndex", int),
  };

let create = (id, name, description, milestone, levelId, sortIndex) => {
  id,
  name,
  description,
  milestone,
  levelId,
  sortIndex,
};

let updateList = (targetGroups, targetGroup) => {
  let oldTargetGroups =
    targetGroups |> List.filter(tg => tg.id !== targetGroup.id);
  oldTargetGroups |> List.rev |> List.append([targetGroup]) |> List.rev;
};

let sort = targetGroups =>
  targetGroups |> List.sort((x, y) => x.sortIndex - y.sortIndex);
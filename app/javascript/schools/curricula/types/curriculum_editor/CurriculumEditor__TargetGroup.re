type t = {
  id: int,
  name: string,
  description: option(string),
  levelId: int,
  milestone: bool,
};

let id = t => t.id;

let name = t => t.name;

let description = t => t.description;

let levelId = t => t.levelId;

let milestone = t => t.milestone;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    name: json |> field("name", string),
    description:
      json |> field("description", nullable(string)) |> Js.Null.toOption,
    levelId: json |> field("levelId", int),
    milestone: json |> field("milestone", bool),
  };

/* let newt = (id, name, description, levelId, milestone) => {
     id,
     name,
     description,
     levelId,
     milestone,
   }; */
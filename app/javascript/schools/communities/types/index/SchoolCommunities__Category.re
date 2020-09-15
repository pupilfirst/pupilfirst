type t = {
  id: string,
  name: string,
  topicsCount: int,
};

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    topicsCount: json |> field("topicsCount", int),
  };

let id = t => t.id;

let name = t => t.name;

let topicsCount = t => t.topicsCount;

let updateName = (name, t) => {
  {...t, name};
};

let make = (id, ~name, ~topicsCount) => {id, name, topicsCount};

let makeFromJs = data => {
  id: data##id,
  name: data##name,
  topicsCount: data##topicsCount,
};

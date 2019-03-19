type t = {
  id: int,
  name: string,
  endsAt: option(string),
};

let name = t => t.name;

let id = t => t.id;

let endsAt = t => t.endsAt;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    name: json |> field("name", string),
    endsAt: json |> field("endsAt", nullable(string)) |> Js.Null.toOption,
  };

let sort = courses => courses |> List.sort((x, y) => x.id - y.id);

let create = (id, name, endsAt) => {id, name, endsAt};
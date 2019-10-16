type t = {
  id: string,
  totalTargets: int,
};

let id = t => t.id;
let totalTargets = t => t.totalTargets;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    totalTargets: json |> field("totalTargets", int),
  };

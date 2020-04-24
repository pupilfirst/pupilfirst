type t = {
  id,
  name: string,
}
and id = string;

let id = t => t.id;
let name = t => t.name;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
  };

let path = t =>
  "/communities/" ++ t.id ++ "/" ++ (t.name |> StringUtils.parameterize);

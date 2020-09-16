type t = {
  id,
  name: string,
}
and id = string;

let id = t => t.id;
let name = t => t.name;

let decode = json =>
  Json.Decode.{
    id: field("id", string, json),
    name: field("name", string, json),
  };

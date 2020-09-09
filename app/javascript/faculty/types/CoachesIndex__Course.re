type t = {
  id,
  name: string,
}
and id = string;

let decode = json =>
  Json.Decode.{
    id: field("id", string, json),
    name: field("name", string, json),
  };

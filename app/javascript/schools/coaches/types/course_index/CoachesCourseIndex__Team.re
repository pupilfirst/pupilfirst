type t = {
  id: string,
  name: string,
  students: array(string),
};

let name = t => t.name;
let id = t => t.id;

let students = t => t.students;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    students: json |> field("students", array(string)),
  };

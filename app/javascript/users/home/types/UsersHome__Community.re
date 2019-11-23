type t = {
  id: string,
  name: string,
  linkedCourses: array(string),
};

let name = t => t.name;
let id = t => t.id;
let linkedCourses = t => t.linkedCourses;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", string),
    name: json |> field("name", string),
    linkedCourses: json |> field("linkedCourses", array(string)),
  };

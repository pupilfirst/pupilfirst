type t = {
  name: string,
  students: list(StudentsPanel__Student.t),
};

let name = t => t.name;

let students = t => t.students;

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    students: json |> field("students", list(StudentsPanel__Student.decode)),
  };

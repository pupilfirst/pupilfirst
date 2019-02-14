type t = {
  name: string,
  students: list(StudentsPanel__Student.t),
  coaches: list(StudentsPanel__Coach.t),
};

let name = t => t.name;

let students = t => t.students;

let coaches = t => t.coaches;

let decode = json =>
  Json.Decode.{
    name: json |> field("name", string),
    students: json |> field("students", list(StudentsPanel__Student.decode)),
    coaches: json |> field("coaches", list(StudentsPanel__Coach.decode)),
  };

type t = {
  id: int,
  name: string,
  students: list(StudentsPanel__Student.t),
  coaches: list(int),
  levelNumber: int,
};

let id = t => t.id;

let name = t => t.name;

let students = t => t.students;

let coaches = t => t.coaches;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    name: json |> field("name", string),
    students: json |> field("students", list(StudentsPanel__Student.decode)),
    coaches: json |> field("coaches", list(int)),
    levelNumber: json |> field("levelNumber", int),
  };

let levelNumber = t => t.levelNumber;
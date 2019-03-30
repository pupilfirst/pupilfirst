type t = {
  id: int,
  name: string,
  students: list(StudentsPanel__Student.t),
  coachIds: list(int),
  levelNumber: int,
};

let id = t => t.id;

let name = t => t.name;

let students = t => t.students;

let coachIds = t => t.coachIds;

let decode = json =>
  Json.Decode.{
    id: json |> field("id", int),
    name: json |> field("name", string),
    students: json |> field("students", list(StudentsPanel__Student.decode)),
    coachIds: json |> field("coaches", list(int)),
    levelNumber: json |> field("levelNumber", int),
  };

let levelNumber = t => t.levelNumber;
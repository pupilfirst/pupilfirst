type t = {
  id: string,
  name: string,
  coachIds: list(string),
  levelId: string,
  accessEndsAt: option(Js.Date.t),
  students: array(StudentsEditor__Student.t),
};

let id = t => t.id;

let name = t => t.name;

let coachIds = t => t.coachIds;

let accessEndsAt = t => t.accessEndsAt;

let levelId = t => t.levelId;

let students = t => t.students;

let singleStudent = t => t.students |> Array.length == 1;

type student = {
  id: string,
  name: string,
  title: string,
  avatarUrl: option(string),
};

type t = {
  id: string,
  name: string,
  levelId: string,
  students: array(student),
  coachUserIds: array(string),
};

let id = t => t.id;
let levelId = t => t.levelId;

let name = t => t.name;

let title = t => t.title;

let students = t => t.students;

let coachUserIds = t => t.coachUserIds;

let studentId = (student: student) => student.id;

let studentName = (student: student) => student.name;

let studentTitle = (student: student) => student.title;

let makeStudent = (~id, ~name, ~title, ~avatarUrl) => {
  id,
  name,
  title,
  avatarUrl,
};

let make = (~id, ~name, ~levelId, ~students, ~coachUserIds) => {
  id,
  name,
  levelId,
  students,
  coachUserIds,
};

let makeFromJS = teamDetails => {
  teamDetails
  |> Js.Array.map(team =>
       switch (team) {
       | Some(team) =>
         let students =
           team##students
           |> Array.map(student =>
                makeStudent(
                  ~id=student##id,
                  ~name=student##name,
                  ~title=student##title,
                  ~avatarUrl=student##avatarUrl,
                )
              );
         [
           make(
             ~id=team##id,
             ~name=team##name,
             ~levelId=team##levelId,
             ~students,
             ~coachUserIds=team##coachUserIds,
           ),
         ];
       | None => []
       }
     );
};

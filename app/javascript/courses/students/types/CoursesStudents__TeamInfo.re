type student = {
  id: string,
  name: string,
};

type t = {
  id: string,
  name: string,
  levelId: string,
  students: array(student),
};

let id = t => t.id;
let levelId = t => t.levelId;

let name = t => t.name;

let students = t => t.students;

let makeStudent = (~id, ~name) => {id, name};

let make = (~id, ~name, ~levelId, ~students) => {
  id,
  name,
  levelId,
  students,
};

let decodeJS = teamDetails => {
  teamDetails
  |> Js.Array.map(team =>
       switch (team) {
       | Some(team) =>
         let students =
           team##students
           |> Array.map(student =>
                makeStudent(~id=student##id, ~name=student##name)
              );
         [
           make(
             ~id=team##id,
             ~name=team##name,
             ~levelId=team##levelId,
             ~students,
           ),
         ];
       | None => []
       }
     );
};

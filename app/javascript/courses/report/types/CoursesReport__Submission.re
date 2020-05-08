type targetRole =
  | Student
  | Team(array(studentId))
and studentId = string;

type t = {
  id: string,
  title: string,
  createdAt: Js.Date.t,
  status: [ | `Submitted | `Failed | `Passed],
  levelId: string,
  targetId: string,
  targetRole,
};

let make =
    (~id, ~title, ~createdAt, ~levelId, ~status, ~targetId, ~targetRole) => {
  id,
  title,
  createdAt,
  status,
  levelId,
  targetId,
  targetRole,
};

let id = t => t.id;

let levelId = t => t.levelId;

let title = t => t.title;

let status = t => t.status;

let createdAt = t => t.createdAt;

let targetId = t => t.targetId;

let targetRole = t => t.targetRole;

let createdAtPretty = t => t.createdAt->DateFns.format("MMMM d, yyyy");

let makeFromJs = submissions => {
  submissions
  |> Js.Array.map(submission =>
       switch (submission) {
       | Some(submission) =>
         let createdAt = submission##createdAt |> DateFns.decodeISO;
         let status =
           switch (submission##passedAt) {
           | Some(_passedAt) => `Passed
           | None =>
             switch (submission##evaluatorId) {
             | Some(_id) => `Failed
             | None => `Submitted
             }
           };
         let targetRole =
           submission##teamTarget ? Team(submission##studentIds) : Student;
         [
           make(
             ~id=submission##id,
             ~title=submission##title,
             ~createdAt,
             ~levelId=submission##levelId,
             ~targetId=submission##targetId,
             ~targetRole,
             ~status,
           ),
         ];
       | None => []
       }
     );
};

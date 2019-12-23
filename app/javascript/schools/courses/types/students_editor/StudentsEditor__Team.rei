type t;

let id: t => string;

let name: t => string;

let coachIds: t => list(string);

let levelId: t => string;

let accessEndsAt: t => option(Js.Date.t);

let students: t => array(StudentsEditor__Student.t);

let singleStudent: t => bool;

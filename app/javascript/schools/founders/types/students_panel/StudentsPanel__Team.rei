type t;

let decode: Js.Json.t => t;

let id: t => int;

let name: t => string;

let students: t => list(StudentsPanel__Student.t);

let coachIds: t => list(int);

let levelNumber: t => int;
type t;

let decode: Js.Json.t => t;

let name: t => string;

let students: t => list(StudentsPanel__Student.t);

let coaches: t => list(StudentsPanel__Coach.t);

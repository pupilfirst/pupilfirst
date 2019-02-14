type t;

let decode: Js.Json.t => t;

let name: t => string;

let students: t => list(StudentsPanel__Student.t);

type t;

let decode: Js.Json.t => t;

let id: t => int;

let name: t => string;

let coachIds: t => list(int);

let levelNumber: t => int;
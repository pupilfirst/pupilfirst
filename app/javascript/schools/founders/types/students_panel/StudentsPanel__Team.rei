type t;

let decode: Js.Json.t => t;

let id: t => string;

let name: t => string;

let coachIds: t => list(string);

let levelNumber: t => int;

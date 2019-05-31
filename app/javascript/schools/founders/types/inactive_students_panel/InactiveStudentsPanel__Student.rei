type t;

let id: t => string;

let userId: t => string;
let teamId: t => string;
let email: t => string;
let tags: t => list(string);

let decode: Js.Json.t => t;

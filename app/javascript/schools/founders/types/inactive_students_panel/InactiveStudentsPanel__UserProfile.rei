type t;


let userId: t => string;
let name: t => string;
let avatarUrl: t => string;

let decode: Js.Json.t => t;

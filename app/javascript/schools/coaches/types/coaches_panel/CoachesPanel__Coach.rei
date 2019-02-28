type t;

let decode: Js.Json.t => t;

let name: t => string;

let id: t => int;

let imageUrl: t => string;

let email: t => string;

let updateInfo: (string, t) => t;

let encode: t => Js.Json.t;
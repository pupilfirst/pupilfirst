type t;

let decode: Js.Json.t => t;

let name: t => string;

let id: t => int;

let avatarUrl: t => string;

let teamId: t => int;

let teamName: t => string;

let email: t => string;

let updateInfo: (string, string, t) => t;

let encode: t => Js.Json.t;

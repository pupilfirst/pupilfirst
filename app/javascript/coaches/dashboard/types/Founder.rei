type t;

let decode: Js.Json.t => t;

let name: t => string;

let id: t => int;

let founderNames: list(t) => string;
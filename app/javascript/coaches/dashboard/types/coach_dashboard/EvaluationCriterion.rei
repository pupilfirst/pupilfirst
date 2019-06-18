type t;

let decode: Js.Json.t => t;

let id: t => int;

let name: t => string;

let make: (int, string) => t;

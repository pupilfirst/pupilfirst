type t;

let name: t => string;

let number: t => int;

let id: t => string;

let decode: Js.Json.t => t;

let unsafeLevelNumber: (array(t), string, string) => string;

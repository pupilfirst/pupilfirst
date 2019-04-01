type t;

let name: t => string;

let email: t => string;

let tags: t => list(string);

let encode: t => Js.Json.t;

let create: (string, string, list(string)) => t;
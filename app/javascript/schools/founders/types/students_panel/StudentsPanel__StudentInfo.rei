type t;

let name: t => string;

let email: t => string;

let encode: t => Js.Json.t;

let create: (string, string) => t;

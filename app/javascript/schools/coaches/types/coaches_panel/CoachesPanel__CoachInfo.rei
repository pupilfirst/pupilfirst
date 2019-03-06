type t;

let name: t => string;

let email: t => string;

let title: t => string;

let encode: t => Js.Json.t;

let create: (string, string, string) => t;
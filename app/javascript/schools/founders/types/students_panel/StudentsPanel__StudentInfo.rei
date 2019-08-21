type t;

let name: t => string;

let email: t => string;

let tags: t => list(string);

let title: t => string;

let affiliation: t => string;

let encode: t => Js.Json.t;

let make: (string, string, string, string, list(string)) => t;

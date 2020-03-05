type t;

let name: t => string;

let email: t => string;

let tags: t => array(string);

let title: t => string;

let affiliation: t => string;

let teamName: t => option(string);

let encode: t => Js.Json.t;

let make:
  (string, string, string, string, array(string), option(string)) => t;

type t;

let name: t => string;

let email: t => string;

let title: t => string;

let affiliation: t => string;

let encode: t => Js.Json.t;

let make:
  (~name: string, ~email: string, ~title: string, ~affiliation: string) => t;

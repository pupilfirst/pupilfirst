type t;

let decode: Js.Json.t => t;

let id: t => string;

let name: t => string;

let make: (~id: string, ~name: string) => t;

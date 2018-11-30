type t;

let decode: Js.Json.t => t;

let value: t => string;

let hint: t => string;

let correctAnswer: t => bool;
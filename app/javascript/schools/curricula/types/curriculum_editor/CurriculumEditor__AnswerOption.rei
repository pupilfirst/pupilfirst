type t;

let answer: t => string;

let description: t => option(string);

let correctAnswer: t => bool;

let empty: unit => t;

let updateAnswer: (t, string) => t;

let create: (string, option(string), bool) => t;
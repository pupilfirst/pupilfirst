type t;

let decode: Js.Json.t => t;

let id: t => int;

let teamId: t => int;

let userId: t => int;

let email: t => string;

let tags: t => list(string);

let updateInfo: (string, string, bool, bool, t) => t;

let encode: t => Js.Json.t;

let exited: t => bool;

let excludedFromLeaderboard: t => bool;
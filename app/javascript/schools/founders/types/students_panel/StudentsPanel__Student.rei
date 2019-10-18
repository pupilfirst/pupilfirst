type t;

let decode: Js.Json.t => t;

let id: t => string;

let teamId: t => string;

let email: t => string;

let tags: t => list(string);

let updateInfo:
  (
    ~exited: bool,
    ~excludedFromLeaderboard: bool,
    ~title: string,
    ~affiliation: option(string),
    ~student: t
  ) =>
  t;

let encode: (string, string, t) => Js.Json.t;

let exited: t => bool;

let excludedFromLeaderboard: t => bool;

let name: t => string;

let avatarUrl: t => option(string);

let title: t => string;

let affiliation: t => option(string);

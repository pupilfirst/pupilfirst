open CoachDashboard__Types;

type t;

let decode: Js.Json.t => t;

let name: t => string;

let id: t => int;

let founderNames: list(t) => string;

let avatarUrl: t => string;

let teamId: t => int;

let withIds: (list(int), list(t)) => list(t);

let inTeam: (Team.t, list(t)) => list(t);

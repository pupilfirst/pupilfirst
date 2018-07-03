type t;

let title: t => string;

let submittedAt: t => DateTime.t;

let description: t => string;

let founderName: t => string;

let startupName: t => string;

let id: t => int;

let links: t => list(Link.t);

let files: t => list(File.t);

let forStartupId: (int, list(t)) => list(t);

let verificationPending: list(t) => list(t);

let verificationComplete: list(t) => list(t);

let decode: Js.Json.t => t;
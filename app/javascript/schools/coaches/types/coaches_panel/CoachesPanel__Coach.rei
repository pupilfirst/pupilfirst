type t;

let decode: Js.Json.t => t;

let name: t => string;

let id: t => int;

let imageUrl: t => string;

let email: t => string;

let title: t => string;

let linkedinUrl: t => option(string);

let public: t => bool;

let connectLink: t => option(string);

let notifyForSubmission: t => bool;

let updateInfo: (string, t) => t;
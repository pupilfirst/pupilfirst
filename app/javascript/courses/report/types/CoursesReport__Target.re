type status = [ | `Pending | `Passed | `Failed | `Submitted];

type t = {
  id: string,
  title: string,
  status,
  levelId: string,
  submittedOn: option(Js.Date.t),
};

let id = t => t.id;

let title = t => t.title;

let levelId = t => t.levelId;

let status = t => t.status;

let submittedOn = t => t.submittedOn;

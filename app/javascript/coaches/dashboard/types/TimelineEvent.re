type status =
  | Verified
  | NotAccepted
  | Pending
  | NeedsImprovement;

type t = {
  id: int,
  title: string,
  description: string,
  status,
  eventOn: string,
  startupId: int,
};

module JsDecode = {
  [@bs.deriving abstract]
  type t = {
    id: int,
    title: string,
    description: string,
    status: string,
    eventOn: string,
    startupId: int,
  };
  let parseStatus = status =>
    switch (status) {
    | "Pending" => Pending
    | "Verified" => Verified
    | "Not Accepted" => NotAccepted
    | "Needs Improvement" => NeedsImprovement
    | _ => failwith("Invalid Status")
    };
};

let create = js_t => {
  id: js_t |> JsDecode.id,
  title: js_t |> JsDecode.title,
  description: js_t |> JsDecode.description,
  status: js_t |> JsDecode.status |> JsDecode.parseStatus,
  eventOn: js_t |> JsDecode.eventOn,
  startupId: js_t |> JsDecode.startupId,
};

let title = t => t.title;

let startupId = t => t.startupId;
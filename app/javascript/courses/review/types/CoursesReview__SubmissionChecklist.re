type result =
  | ShortText(string)
  | LongText(string)
  | Link(string)
  | Files(array(string))
  | MultiChoice(string)
  | None;

type status =
  | Passed
  | Failed
  | Pending;

type t = {
  title: string,
  result,
  status,
};

let title = t => t.title;
let result = t => t.result;
let status = t => t.status;

let make = (~title, ~result, ~status) => {title, result, status};

let makeResult = data => {
  switch (data##result) {
  | Some(result) =>
    switch (data##kind) {
    | "short_text" => ShortText(result)
    | "long_text" => LongText(result)
    | "link" => Link(result)
    | "multi_choice" => MultiChoice(result)
    | _ => None
    }
  | None => None
  };
};

let makeStatus = data => {
  switch (data##status) {
  | "pending" => Pending
  | "passed" => Passed
  | "failed" => Failed
  | unkownStatus =>
    Rollbar.error(
      "Unkown status:"
      ++ unkownStatus
      ++ "recived in CourseReview__SubmissionChecklist",
    );
    Pending;
  };
};

let makeArrayFromJs = data => {
  data
  |> Js.Array.map(r =>
       make(~title=r##title, ~result=makeResult(r), ~status=makeStatus(r))
     );
};

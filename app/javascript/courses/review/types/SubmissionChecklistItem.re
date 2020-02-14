type attachment = {
  name: string,
  url: string,
};

type result =
  | ShortText(string)
  | LongText(string)
  | Link(string)
  | Files(array(attachment))
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
let attachmentName = attachment => attachment.name;
let attachmentUrl = attachment => attachment.url;

let make = (~title, ~result, ~status) => {title, result, status};

let makeAttachment = (~name, ~url) => {name, url};

let makeAttachments = data =>
  data |> Js.Array.map(a => makeAttachment(~url=a##url, ~name=a##title));

let makeResult = (data, attachments) => {
  switch (data##result) {
  | Some(result) =>
    switch (data##kind) {
    | "short_text" => ShortText(result)
    | "long_text" => LongText(result)
    | "link" => Link(result)
    | "multi_choice" => MultiChoice(result)
    | "files" => Files(makeAttachments(attachments))
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

let makeArrayFromJs = (attachments, checklist) => {
  checklist
  |> Js.Array.map(c =>
       make(
         ~title=c##title,
         ~result=makeResult(c, attachments),
         ~status=makeStatus(c),
       )
     );
};

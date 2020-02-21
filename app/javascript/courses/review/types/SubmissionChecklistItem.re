type attachment = {
  id: string,
  name: string,
  url: string,
};

type result =
  | ShortText(string)
  | LongText(string)
  | Link(string)
  | Files(array(attachment))
  | MultiChoice(string);

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

let makeAttachment = (~name, ~url, ~id) => {name, url, id};

let makeAttachments = data =>
  data
  |> Js.Array.map(a => makeAttachment(~url=a##url, ~name=a##title, ~id=a##id));

let makeResult = (result, kind, attachments) => {
  switch (kind) {
  | "shortText" => ShortText(result)
  | "longText" => LongText(result)
  | "link" => Link(result)
  | "multiChoice" => MultiChoice(result)
  | "files" => Files(attachments)
  | randomKind =>
    Rollbar.error(
      "Unkown kind: "
      ++ randomKind
      ++ "recived in CurriculumEditor__TargetChecklistItem",
    );
    ShortText("Error");
  };
};

let makeStatus = data => {
  switch (data) {
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
         ~result=
           makeResult(c##result, c##kind, makeAttachments(attachments)),
         ~status=makeStatus(c##status),
       )
     );
};

let decodeAttachment = json =>
  Json.Decode.{
    name: json |> field("name", string),
    url: json |> field("url", string),
    id: json |> field("id", string),
  };

let decode = (attachments, json) => {
  Json.Decode.{
    result:
      makeResult(
        json |> field("result", string),
        json |> field("kind", string),
        attachments,
      ),
    status: makeStatus(json |> field("status", string)),
    title: json |> field("title", string),
  };
};

let updateStatus = (checklist, index, status) =>
  checklist
  |> Array.mapi((i, t) => {
       i == index ? make(~title=t.title, ~result=t.result, ~status) : t
     });

let makePending = (index, checklist) =>
  updateStatus(checklist, index, Pending);

let makeFailed = (index, checklist) =>
  updateStatus(checklist, index, Failed);

let makePassed = (index, checklist) =>
  updateStatus(checklist, index, Passed);

let encodeKind = t =>
  switch (t.result) {
  | ShortText(_) => "shortText"
  | LongText(_) => "longText"
  | Link(_) => "link"
  | Files(_) => "files"
  | MultiChoice(_) => "multiChoice"
  };

let encodeResult = t =>
  switch (t.result) {
  | ShortText(t)
  | LongText(t)
  | Link(t) => t
  | MultiChoice(_)
  | Files(_) => "files"
  };

let encodeStatus = t => {
  switch (t.status) {
  | Pending => "pending"
  | Passed => "passed"
  | Failed => "failed"
  };
};

let encode = t =>
  Json.Encode.(
    object_([
      ("title", t.title |> string),
      ("kind", encodeKind(t) |> string),
      ("status", encodeStatus(t) |> string),
      ("result", encodeResult(t) |> string),
    ])
  );

let encodeArray = checklist => checklist |> Json.Encode.(array(encode));

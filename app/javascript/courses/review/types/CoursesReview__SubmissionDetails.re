type attachment = {
  title: option(string),
  url: string,
};

type feedback = {
  coachId: string,
  createdAt: string,
  value: string,
  id: string,
};

type grade = {
  evaluationCriterionId: string,
  grade: int,
  id: string,
};

type t = {
  id: string,
  description: string,
  createdAt: string,
  failed: bool,
  attachments: list(attachment),
  feedback: list(feedback),
  grades: list(grade),
};
let id = t => t.id;
let createdAt = t => t.createdAt;
let failed = t => t.failed;
let description = t => t.description;
let createdAtDate = t => t |> createdAt |> DateFns.parseString;
let attachments = t => t.attachments;
let feedback = t => t.feedback;
let title = attachment => attachment.title;
let url = attachment => attachment.url;
let value = feedback => feedback.value;
let createdAtPretty = t =>
  t |> createdAtDate |> DateFns.format("MMMM D, YYYY");

let timeDistance = t =>
  t |> createdAtDate |> DateFns.distanceInWordsToNow(~addSuffix=true);

let sort = submissions =>
  submissions
  |> List.sort((x, y) =>
       DateFns.differenceInSeconds(
         y.createdAt |> DateFns.parseString,
         x.createdAt |> DateFns.parseString,
       )
       |> int_of_float
     );

let make =
    (~id, ~description, ~createdAt, ~failed, ~attachments, ~feedback, ~grades) => {
  id,
  description,
  createdAt,
  failed,
  attachments,
  feedback,
  grades,
};

let makeGrade = (~evaluationCriterionId, ~grade, ~id) => {
  evaluationCriterionId,
  grade,
  id,
};

let makeAttachment = (~title, ~url) => {title, url};

let makeFeedback = (~coachId, ~createdAt, ~value, ~id) => {
  coachId,
  createdAt,
  value,
  id,
};

let makeT = details =>
  details
  |> Js.Array.map(s =>
       make(
         ~id=s##id,
         ~description=s##description,
         ~createdAt=s##createdAt,
         ~failed=s##failed,
         ~attachments=
           s##attachments
           |> Js.Array.map(a => makeAttachment(~url=a##url, ~title=a##title))
           |> Array.to_list,
         ~feedback=
           s##feedback
           |> Js.Array.map(f =>
                makeFeedback(
                  ~id=f##id,
                  ~coachId=f##coachId,
                  ~createdAt=f##createdAt,
                  ~value=f##value,
                )
              )
           |> Array.to_list,
         ~grades=
           s##grades
           |> Js.Array.map(g =>
                makeGrade(
                  ~evaluationCriterionId=g##evaluationCriterionId,
                  ~id=g##id,
                  ~grade=g##grade,
                )
              )
           |> Array.to_list,
       )
     )
  |> Array.to_list;

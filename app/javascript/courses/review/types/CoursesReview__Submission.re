type attachment = {
  title: option(string),
  url: string,
};

type t = {
  id: string,
  description: string,
  createdAt: Js.Date.t,
  passedAt: option(Js.Date.t),
  evaluatorName: option(string),
  evaluatedAt: option(Js.Date.t),
  attachments: array(attachment),
  feedback: array(CoursesReview__Feedback.t),
  grades: array(CoursesReview__Grade.t),
};
let id = t => t.id;
let createdAt = t => t.createdAt;
let passedAt = t => t.passedAt;
let evaluatorName = t => t.evaluatorName;
let evaluatedAt = t => t.evaluatedAt;
let description = t => t.description;
let attachments = t => t.attachments;
let grades = t => t.grades;
let feedback = t => t.feedback;
let title = attachment => attachment.title;
let url = attachment => attachment.url;
let prettyDate = date => date |> DateFns.format("MMMM D, YYYY");

let timeDistance = t =>
  t.createdAt |> DateFns.distanceInWordsToNow(~addSuffix=true);

let sort = submissions =>
  submissions
  |> ArrayUtils.copyAndSort((x, y) =>
       DateFns.differenceInSeconds(y.createdAt, x.createdAt) |> int_of_float
     );

let make =
    (
      ~id,
      ~description,
      ~createdAt,
      ~passedAt,
      ~evaluatorName,
      ~attachments,
      ~feedback,
      ~grades,
      ~evaluatedAt,
    ) => {
  id,
  description,
  createdAt,
  passedAt,
  evaluatorName,
  attachments,
  feedback,
  grades,
  evaluatedAt,
};

let makeAttachment = (~title, ~url) => {title, url};

let decodeJS = details =>
  details
  |> Js.Array.map(s =>
       make(
         ~id=s##id,
         ~description=s##description,
         ~createdAt=s##createdAt |> DateFns.parseString,
         ~passedAt=s##passedAt |> OptionUtils.map(DateFns.parseString),
         ~evaluatorName=s##evaluatorName,
         ~evaluatedAt=s##evaluatedAt |> OptionUtils.map(DateFns.parseString),
         ~attachments=
           s##attachments
           |> Js.Array.map(a => makeAttachment(~url=a##url, ~title=a##title)),
         ~feedback=
           s##feedback
           |> Js.Array.map(f =>
                CoursesReview__Feedback.make(
                  ~id=f##id,
                  ~coachName=f##coachName,
                  ~coachAvatarUrl=f##coachAvatarUrl,
                  ~coachTitle=f##coachTitle,
                  ~createdAt=f##createdAt |> DateFns.parseString,
                  ~value=f##value,
                )
              ),
         ~grades=
           s##grades
           |> Js.Array.map(g =>
                CoursesReview__Grade.make(
                  ~evaluationCriterionId=g##evaluationCriterionId,
                  ~value=g##grade,
                )
              ),
       )
     );

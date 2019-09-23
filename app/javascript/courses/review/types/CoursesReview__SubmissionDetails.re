type attachment = {
  title: option(string),
  url: string,
};

type t = {
  id: string,
  description: string,
  createdAt: string,
  passedAt: option(Js.Date.t),
  evaluatorName: option(string),
  attachments: array(attachment),
  feedback: array(CoursesReview__Feedback.t),
  grades: array(CoursesReview__Grade.t),
  evaluationCriteria: array(CoursesReview__EvaluationCriterion.t),
};
let id = t => t.id;
let createdAt = t => t.createdAt;
let passedAt = t => t.passedAt;
let evaluatorName = t => t.evaluatorName;
let description = t => t.description;
let createdAtDate = t => t |> createdAt |> DateFns.parseString;
let attachments = t => t.attachments;
let evaluationCriteria = t => t.evaluationCriteria;
let grades = t => t.grades;
let feedback = t => t.feedback;
let title = attachment => attachment.title;
let url = attachment => attachment.url;
let createdAtPretty = t =>
  t |> createdAtDate |> DateFns.format("MMMM D, YYYY");

let timeDistance = t =>
  t |> createdAtDate |> DateFns.distanceInWordsToNow(~addSuffix=true);

let sort = submissions =>
  submissions
  |> ArrayUtils.copyAndSort((x, y) =>
       DateFns.differenceInSeconds(
         y.createdAt |> DateFns.parseString,
         x.createdAt |> DateFns.parseString,
       )
       |> int_of_float
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
      ~evaluationCriteria,
    ) => {
  id,
  description,
  createdAt,
  passedAt,
  evaluatorName,
  attachments,
  feedback,
  grades,
  evaluationCriteria,
};

let makeAttachment = (~title, ~url) => {title, url};

let decodeJS = details =>
  details
  |> Js.Array.map(s =>
       make(
         ~id=s##id,
         ~description=s##description,
         ~createdAt=s##createdAt,
         ~passedAt=s##passedAt |> Date.parseOption,
         ~evaluatorName=s##evaluatorName,
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
         ~evaluationCriteria=
           s##evaluationCriteria
           |> Js.Array.map(ec =>
                CoursesReview__EvaluationCriterion.make(
                  ~id=ec##id,
                  ~name=ec##name,
                )
              ),
       )
     );

type attachment = {
  title: option(string),
  url: string,
};
type grade = {
  evaluationCriterionId: string,
  grade: int,
  id: string,
};

type evaluationCriterion = {
  id: string,
  name: string,
};

type t = {
  id: string,
  description: string,
  createdAt: string,
  passedAt: option(string),
  evaluatorId: option(string),
  attachments: array(attachment),
  feedback: array(CoursesReview__Feedback.t),
  grades: array(grade),
  evaluationCriteria: array(evaluationCriterion),
};
let id = t => t.id;
let createdAt = t => t.createdAt;
let passedAt = t => t.passedAt;
let evaluatorId = t => t.evaluatorId;
let description = t => t.description;
let createdAtDate = t => t |> createdAt |> DateFns.parseString;
let attachments = t => t.attachments;
let evaluationCriteria = t => t.evaluationCriteria;
let grades = t => t.grades;
let feedback = t => t.feedback;
let title = attachment => attachment.title;
let url = attachment => attachment.url;
let evaluationCriterionName = evaluationCriterion => evaluationCriterion.name;
let evaluationCriterion = evaluationCriterion => evaluationCriterion.id;
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
      ~evaluatorId,
      ~attachments,
      ~feedback,
      ~grades,
      ~evaluationCriteria,
    ) => {
  id,
  description,
  createdAt,
  passedAt,
  evaluatorId,
  attachments,
  feedback,
  grades,
  evaluationCriteria,
};

let makeGrade = (~evaluationCriterionId, ~grade, ~id) => {
  evaluationCriterionId,
  grade,
  id,
};

let makeAttachment = (~title, ~url) => {title, url};

let makeEvaluationCriteria = (~id, ~name) => {id, name};

let decodeJS = details =>
  details
  |> Js.Array.map(s =>
       make(
         ~id=s##id,
         ~description=s##description,
         ~createdAt=s##createdAt,
         ~passedAt=s##passedAt,
         ~evaluatorId=s##evaluatorId,
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
                  ~createdAt=f##createdAt,
                  ~value=f##value,
                )
              ),
         ~grades=
           s##grades
           |> Js.Array.map(g =>
                makeGrade(
                  ~evaluationCriterionId=g##evaluationCriterionId,
                  ~id=g##id,
                  ~grade=g##grade,
                )
              ),
         ~evaluationCriteria=
           s##evaluationCriteria
           |> Js.Array.map(ec =>
                makeEvaluationCriteria(~id=ec##id, ~name=ec##name)
              ),
       )
     );

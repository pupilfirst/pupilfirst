type t = {
  submissions: array(CoursesReview__Submission.t),
  targetId: string,
  targetTitle: string,
  userNames: string,
  levelNumber: string,
  evaluationCriteria: array(CoursesReview__EvaluationCriterion.t),
};
let submissions = t => t.submissions;
let targetId = t => t.targetId;
let targetTitle = t => t.targetTitle;
let levelNumber = t => t.levelNumber;
let userNames = t => t.userNames;
let evaluationCriteria = t => t.evaluationCriteria;
let make =
    (
      ~submissions,
      ~targetId,
      ~targetTitle,
      ~userNames,
      ~levelNumber,
      ~evaluationCriteria,
    ) => {
  submissions,
  targetId,
  targetTitle,
  userNames,
  levelNumber,
  evaluationCriteria,
};

let decodeJS = details =>
  make(
    ~submissions=details##submissions |> CoursesReview__Submission.decodeJS,
    ~targetId=details##targetId,
    ~targetTitle=details##targetTitle,
    ~userNames=details##userNames,
    ~levelNumber=details##levelNumber,
    ~evaluationCriteria=
      details##evaluationCriteria
      |> Js.Array.map(ec =>
           CoursesReview__EvaluationCriterion.make(~id=ec##id, ~name=ec##name)
         ),
  );

let updateSubmission = (t, submission) =>
  make(
    ~submissions=
      t.submissions
      |> Js.Array.filter(s =>
           s
           |> CoursesReview__Submission.id
           != (submission |> CoursesReview__Submission.id)
         )
      |> Array.append([|submission|]),
    ~targetId=t.targetId,
    ~targetTitle=t.targetTitle,
    ~userNames=t.userNames,
    ~levelNumber=t.levelNumber,
    ~evaluationCriteria=t.evaluationCriteria,
  );

type t = {
  pendingUserIds: list(string),
  submissions: list(CoursesCurriculum__Submission.t),
  submissionAttachments: list(CoursesCurriculum__SubmissionAttachment.t),
  feedback: list(CoursesCurriculum__Feedback.t),
  quizQuestions: list(CoursesCurriculum__QuizQuestion.t),
  contentBlocks: list(ContentBlock.t),
  communities: list(CoursesCurriculum__Community.t),
  linkToComplete: option(string),
  evaluated: bool,
  grading: list(CoursesCurriculum__Grade.t),
  completionInstructions: option(string),
};

let submissions = t => t.submissions;
let submissionAttachments = t => t.submissionAttachments;
let pendingUserIds = t => t.pendingUserIds;
let feedback = t => t.feedback;

type completionType =
  | Evaluated
  | TakeQuiz
  | LinkToComplete
  | MarkAsComplete;

let decode = json =>
  Json.Decode.{
    pendingUserIds: json |> field("pendingUserIds", list(string)),
    submissions:
      json
      |> field("submissions", list(CoursesCurriculum__Submission.decode)),
    submissionAttachments:
      json
      |> field(
           "submissionAttachments",
           list(CoursesCurriculum__SubmissionAttachment.decode),
         ),
    feedback:
      json |> field("feedback", list(CoursesCurriculum__Feedback.decode)),
    quizQuestions:
      json
      |> field("quizQuestions", list(CoursesCurriculum__QuizQuestion.decode)),
    contentBlocks: json |> field("contentBlocks", list(ContentBlock.decode)),
    communities:
      json |> field("communities", list(CoursesCurriculum__Community.decode)),
    linkToComplete:
      json |> field("linkToComplete", nullable(string)) |> Js.Null.toOption,
    evaluated: json |> field("evaluated", bool),
    grading: json |> field("grading", list(CoursesCurriculum__Grade.decode)),
    completionInstructions:
      json
      |> field("completionInstructions", nullable(string))
      |> Js.Null.toOption,
  };

let computeCompletionType = targetDetails => {
  let evaluated = targetDetails.evaluated;
  let hasQuiz = targetDetails.quizQuestions |> ListUtils.isNotEmpty;
  let hasLinkToComplete =
    switch (targetDetails.linkToComplete) {
    | Some(_) => true
    | None => false
    };
  switch (evaluated, hasQuiz, hasLinkToComplete) {
  | (true, _, _) => Evaluated
  | (false, true, _) => TakeQuiz
  | (false, false, true) => LinkToComplete
  | (_, _, _) => MarkAsComplete
  };
};

let contentBlocks = t => t.contentBlocks;
let quizQuestions = t => t.quizQuestions;
let communities = t => t.communities;
let linkToComplete = t => t.linkToComplete;
let evaluated = t => t.evaluated;

let completionInstructions = t => t.completionInstructions;

let grades = (submissionId, t) =>
  t.grading
  |> List.filter(grade =>
       grade |> CoursesCurriculum__Grade.submissionId == submissionId
     );

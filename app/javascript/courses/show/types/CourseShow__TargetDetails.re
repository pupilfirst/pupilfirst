type t = {
  pendingUserIds: list(string),
  submissions: list(CourseShow__Submission.t),
  submissionAttachments: list(CourseShow__SubmissionAttachment.t),
  feedback: list(CourseShow__Feedback.t),
  quizQuestions: list(CourseShow__QuizQuestion.t),
  contentBlocks: list(CourseShow__ContentBlock.t),
  communities: list(CourseShow__Community.t),
  linkToComplete: option(string),
  evaluated: bool,
  grading: list(CoursesShow__Grade.t),
};

let submissions = t => t.submissions;
let submissionAttachments = t => t.submissionAttachments;
let pendingUserIds = t => t.pendingUserIds;

type completionType =
  | Evaluated
  | TakeQuiz
  | LinkToComplete
  | MarkAsComplete;

let decode = json =>
  Json.Decode.{
    pendingUserIds: json |> field("pendingUserIds", list(string)),
    submissions:
      json |> field("submissions", list(CourseShow__Submission.decode)),
    submissionAttachments:
      json
      |> field(
           "submissionAttachments",
           list(CourseShow__SubmissionAttachment.decode),
         ),
    feedback: json |> field("feedback", list(CourseShow__Feedback.decode)),
    quizQuestions:
      json |> field("quizQuestions", list(CourseShow__QuizQuestion.decode)),
    contentBlocks:
      json |> field("contentBlocks", list(CourseShow__ContentBlock.decode)),
    communities:
      json |> field("communities", list(CourseShow__Community.decode)),
    linkToComplete:
      json |> field("linkToComplete", nullable(string)) |> Js.Null.toOption,
    evaluated: json |> field("evaluated", bool),
    grading: json |> field("grading", list(CoursesShow__Grade.decode)),
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

let grades = (submissionId, t) =>
  t.grading
  |> List.filter(grade =>
       grade |> CoursesShow__Grade.submissionId == submissionId
     );
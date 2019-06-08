type t = {
  pendingStudentIds: list(string),
  latestSubmissionDetails: option(CourseShow__SubmissionDetails.t),
  latestSubmissionAttachments: list(CourseShow__SubmissionAttachment.t),
  latestFeedback: option(CourseShow__Feedback.t),
  quizQuestions: list(CourseShow__QuizQuestion.t),
  contentBlocks: list(CourseShow__ContentBlock.t),
  communities: list(CourseShow__Community.t),
};

let decode = json =>
  Json.Decode.{
    pendingStudentIds: json |> field("pendingStudentIds", list(string)),
    latestSubmissionDetails:
      json
      |> field(
           "latestSubmissionDetails",
           nullable(CourseShow__SubmissionDetails.decode),
         )
      |> Js.Null.toOption,
    latestSubmissionAttachments:
      json
      |> field(
           "latestSubmissionAttachments",
           list(CourseShow__SubmissionAttachment.decode),
         ),
    latestFeedback:
      json
      |> field("latestFeedback", nullable(CourseShow__Feedback.decode))
      |> Js.Null.toOption,
    quizQuestions:
      json |> field("quizQuestions", list(CourseShow__QuizQuestion.decode)),
    contentBlocks:
      json |> field("contentBlocks", list(CourseShow__ContentBlock.decode)),
    communities:
      json |> field("communities", list(CourseShow__Community.decode)),
  };

let contentBlocks = t => t.contentBlocks;
let quizQuestions = t => t.quizQuestions;
let communities = t => t.communities;
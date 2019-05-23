type t = {
  pendingStudentIds: list(string),
  latestSubmissionDetails: CourseShow__SubmissionDetails.t,
  latestSubmissionAttachments: list(CourseShow__SubmissionAttachment.t),
  latestFeedback: option(CourseShow__Feedback.t),
  questions: list(CourseShow__QuizQuestion.t),
  contentBlocks: list(CourseShow__ContentBlock.t),
};

let decode = json =>
  Json.Decode.{
    pendingStudentIds: json |> field("pendingStudentIds", list(string)),
    latestSubmissionDetails:
      json
      |> field(
           "latestSubmissionDetails",
           CourseShow__SubmissionDetails.decode,
         ),
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
    questions:
      json |> field("quizQuestions", list(CourseShow__QuizQuestion.decode)),
    contentBlocks:
      json |> field("contentBlocks", list(CourseShow__ContentBlock.decode)),
  };
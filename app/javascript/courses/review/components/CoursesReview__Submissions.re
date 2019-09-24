[@bs.config {jsx: 3}];

open CoursesReview__Types;
let str = React.string;

type state = {submission: SubmissionDetails.t};

let showSubmissionStatus = submission => {
  let (text, classes) =
    switch (
      submission |> SubmissionDetails.passedAt,
      submission |> SubmissionDetails.evaluatorName,
    ) {
    | (None, None) => (
        "Pending",
        "bg-orange-100 border border-orange-500 text-orange-800 ",
      )
    | (None, Some(_)) => (
        "Failed",
        "bg-red-100 border border-red-500 text-red-700",
      )
    | (Some(_), None)
    | (Some(_), Some(_)) => (
        "Passed",
        "bg-green-100 border border-green-500 text-green-800",
      )
    };
  <div className={"font-semibold px-3 py-px rounded " ++ classes}>
    {text |> str}
  </div>;
};

let showFeedbackSent = feedbackSent =>
  feedbackSent ?
    <div
      className="bg-primary-100 text-primary-600 border border-transparent font-semibold px-3 py-px rounded mr-3">
      {"Feedback Sent" |> str}
    </div> :
    React.null;

let iconSpan = (iconClasses, attachment) => {
  let faClasses =
    switch (attachment |> SubmissionDetails.title) {
    | Some(_) => "far fa-file"
    | None => "fas fa-link"
    };
  <span
    className={
      "flex h-full w-8 justify-center items-center p-2 " ++ iconClasses
    }>
    <i className=faClasses />
  </span>;
};
let showSubmissions = attachments =>
  switch (attachments) {
  | [||] => React.null
  | attachments =>
    <div className="mt-3">
      <h5 className="text-xs font-semibold"> {"Attachments" |> str} </h5>
      <div className="flex flex-wrap">
        {
          attachments
          |> Array.map(attachment => {
               let (
                 key,
                 containerClasses,
                 iconClasses,
                 textClasses,
                 text,
                 url,
               ) =
                 switch (attachment |> SubmissionDetails.title) {
                 | Some(title) => (
                     "file-" ++ (attachment |> SubmissionDetails.url),
                     "border-primary-400 bg-primary-200 text-primary-500 hover:border-primary-600 hover:text-primary-700",
                     "bg-primary-200",
                     "bg-primary-100",
                     title,
                     attachment |> SubmissionDetails.url,
                   )
                 | None => (
                     attachment |> SubmissionDetails.url,
                     "border-blue-400 bg-blue-200 text-blue-700 hover:border-blue-600 hover:text-blue-800",
                     "bg-blue-200",
                     "bg-blue-100",
                     attachment |> SubmissionDetails.url,
                     attachment |> SubmissionDetails.url,
                   )
                 };

               <a
                 href=url
                 target="_blank"
                 className={
                   "mt-2 mr-3 flex items-center border overflow-hidden shadow rounded hover:shadow-md  "
                   ++ containerClasses
                 }>
                 {iconSpan(iconClasses, attachment)}
                 <span
                   className={
                     "course-show-attachments__attachment-title rounded text-xs font-semibold inline-block whitespace-normal truncate w-32 md:w-42 h-full px-3 py-1 leading-loose "
                     ++ textClasses
                   }>
                   {text |> str}
                 </span>
               </a>;
             })
          |> React.array
        }
      </div>
    </div>
  };

let cardClasses = submission =>
  "mt-6 rounded-b-lg bg-white border-t-3 shadow "
  ++ (
    switch (
      submission |> SubmissionDetails.passedAt,
      submission |> SubmissionDetails.evaluatorName,
    ) {
    | (None, None) => "border-orange-300"
    | (None, Some(_)) => "border-red-500"
    | (Some(_), None)
    | (Some(_), Some(_)) => "border-green-500"
    }
  );

let updateGradingCB =
    (
      ~grades,
      ~passed,
      ~newFeedback,
      ~submission,
      ~currentCoach,
      ~updateSubmissionCB,
    ) => {
  let feedback =
    newFeedback == "" ?
      submission |> SubmissionDetails.feedback :
      submission
      |> SubmissionDetails.feedback
      |> Array.append([|
           Feedback.make(
             ~coachName=currentCoach |> Coach.name,
             ~coachAvatarUrl=currentCoach |> Coach.avatarUrl,
             ~coachTitle=currentCoach |> Coach.title,
             ~createdAt=Js.Date.make(),
             ~value=newFeedback,
             ~id="1111",
           ),
         |]);

  let passedAt = passed ? Some(Js.Date.make()) : None;

  let newSubmission =
    SubmissionDetails.make(
      ~id=submission |> SubmissionDetails.id,
      ~description=submission |> SubmissionDetails.description,
      ~createdAt=submission |> SubmissionDetails.createdAt,
      ~passedAt,
      ~evaluatorName=Some(currentCoach |> Coach.name),
      ~attachments=submission |> SubmissionDetails.attachments,
      ~feedback,
      ~grades,
      ~evaluationCriteria=submission |> SubmissionDetails.evaluationCriteria,
    );
  updateSubmissionCB(newSubmission);
};

[@react.component]
let make =
    (
      ~authenticityToken,
      ~submission,
      ~gradeLabels,
      ~passGrade,
      ~updateSubmissionCB,
      ~submissionNumber,
      ~currentCoach,
    ) => {
  let (state, setState) = React.useState(() => {submission: submission});
  <div className={cardClasses(submission)}>
    <div
      className="p-4 md:px-6 md:py-5 border-b bg-white flex flex-col sm:flex-row items-center justify-between">
      <div className="flex flex-col w-full sm:w-auto">
        <h2 className="font-semibold text-sm lg:text-base leading-tight">
          {"Submission " ++ (submissionNumber |> string_of_int) |> str}
        </h2>
        <span className="text-xs text-gray-800 pt-px">
          {"on " ++ (submission |> SubmissionDetails.createdAtPretty) |> str}
        </span>
      </div>
      <div className="text-xs flex w-full sm:w-auto mt-2 sm:mt-0">
        {
          showFeedbackSent(
            submission |> SubmissionDetails.feedback |> ArrayUtils.isNotEmpty,
          )
        }
        {showSubmissionStatus(submission)}
      </div>
    </div>
    <div className="p-4 md:px-6 md:pt-2 bg-gray-100 border-b">
      <MarkdownBlock
        profile=Markdown.Permissive
        markdown={submission |> SubmissionDetails.description}
      />
      {showSubmissions(submission |> SubmissionDetails.attachments)}
    </div>
    <CoursesReview__GradeCard
      authenticityToken
      submissionId={submission |> SubmissionDetails.id}
      gradeLabels
      evaluvationCriteria={submission |> SubmissionDetails.evaluationCriteria}
      grades={submission |> SubmissionDetails.grades}
      passGrade
      passedAt={submission |> SubmissionDetails.passedAt}
      feedback={submission |> SubmissionDetails.feedback}
      updateGradingCB={
        updateGradingCB(~submission, ~currentCoach, ~updateSubmissionCB)
      }
    />
    <CoursesReview__ShowFeedback
      authenticityToken
      feedback={submission |> SubmissionDetails.feedback}
      reviewed={
        submission |> SubmissionDetails.grades |> ArrayUtils.isNotEmpty
      }
    />
  </div>;
};
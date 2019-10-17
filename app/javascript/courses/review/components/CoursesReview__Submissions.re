[@bs.config {jsx: 3}];

open CoursesReview__Types;
let str = React.string;

let showSubmissionStatus = submission => {
  let (text, classes) =
    switch (
      submission |> Submission.passedAt,
      submission |> Submission.evaluatorName,
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
  feedbackSent
    ? <div
        className="bg-primary-100 text-primary-600 border border-transparent font-semibold px-3 py-px rounded mr-3">
        {"Feedback Sent" |> str}
      </div>
    : React.null;

let iconSpan = (iconClasses, attachment) => {
  let faClasses =
    switch (attachment |> Submission.title) {
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
        {attachments
         |> Array.map(attachment => {
              let (key, containerClasses, iconClasses, textClasses, text, url) =
                switch (attachment |> Submission.title) {
                | Some(title) => (
                    "file-" ++ (attachment |> Submission.url),
                    "border-primary-400 bg-primary-200 text-primary-500 hover:border-primary-600 hover:text-primary-700",
                    "bg-primary-200",
                    "bg-primary-100",
                    title,
                    attachment |> Submission.url,
                  )
                | None => (
                    attachment |> Submission.url,
                    "border-blue-400 bg-blue-200 text-blue-700 hover:border-blue-600 hover:text-blue-800",
                    "bg-blue-200",
                    "bg-blue-100",
                    attachment |> Submission.url,
                    attachment |> Submission.url,
                  )
                };

              <a
                key
                href=url
                target="_blank"
                className={
                  "mt-2 mr-3 flex items-center border overflow-hidden shadow rounded hover:shadow-md "
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
         |> React.array}
      </div>
    </div>
  };

let cardClasses = submission =>
  "mt-6 rounded-b-lg bg-white border-t-3 "
  ++ (
    switch (
      submission |> Submission.passedAt,
      submission |> Submission.evaluatorName,
    ) {
    | (None, None) => "border-orange-300"
    | (None, Some(_)) => "border-red-500"
    | (Some(_), None)
    | (Some(_), Some(_)) => "border-green-500"
    }
  );

let updateSubmission =
    (
      ~feedackUpdate,
      ~grades,
      ~passed,
      ~newFeedback,
      ~submission,
      ~currentCoach,
      ~updateSubmissionCB,
    ) => {
  let feedback =
    switch (newFeedback) {
    | Some(f) =>
      f == ""
        ? submission |> Submission.feedback
        : submission
          |> Submission.feedback
          |> Array.append([|
               Feedback.make(
                 ~coachName=currentCoach |> Coach.name,
                 ~coachAvatarUrl=currentCoach |> Coach.avatarUrl,
                 ~coachTitle=currentCoach |> Coach.title,
                 ~createdAt=Js.Date.make(),
                 ~value=f,
                 ~id=Js.Date.now() |> Js.Float.toString,
               ),
             |])
    | None => submission |> Submission.feedback
    };

  let (passedAt, evaluatedAt, newGrades) =
    switch (passed) {
    | Some(p) => (
        p ? Some(Js.Date.make()) : None,
        Some(Js.Date.make()),
        grades,
      )
    | None => (
        submission |> Submission.passedAt,
        submission |> Submission.evaluatedAt,
        submission |> Submission.grades,
      )
    };

  let newSubmission =
    Submission.make(
      ~id=submission |> Submission.id,
      ~description=submission |> Submission.description,
      ~createdAt=submission |> Submission.createdAt,
      ~passedAt,
      ~evaluatorName=Some(currentCoach |> Coach.name),
      ~attachments=submission |> Submission.attachments,
      ~feedback,
      ~grades=newGrades,
      ~evaluatedAt,
    );
  updateSubmissionCB(feedackUpdate, newSubmission);
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
      ~evaluationCriteria,
      ~reviewChecklist,
    ) =>
  <div
    ariaLabel={"submissions-overlay-card-" ++ (submission |> Submission.id)}
    className={cardClasses(submission)}>
    <div className="rounded-b-lg shadow-md">
      <div
        className="p-4 md:px-6 md:py-5 border-b bg-white flex flex-col sm:flex-row items-center justify-between">
        <div className="flex flex-col w-full sm:w-auto">
          <h2 className="font-semibold text-sm lg:text-base leading-tight">
            {"Submission #" ++ (submissionNumber |> string_of_int) |> str}
          </h2>
          <span className="text-xs text-gray-800 pt-px">
            {submission |> Submission.createdAt |> Submission.prettyDate |> str}
          </span>
        </div>
        <div className="text-xs flex w-full sm:w-auto mt-2 sm:mt-0">
          {showFeedbackSent(
             submission |> Submission.feedback |> ArrayUtils.isNotEmpty,
           )}
          {showSubmissionStatus(submission)}
        </div>
      </div>
      <div className="p-4 md:px-6 md:pt-2 bg-gray-100 border-b">
        <MarkdownBlock
          profile=Markdown.Permissive
          markdown={submission |> Submission.description}
        />
        {showSubmissions(submission |> Submission.attachments)}
      </div>
      <CoursesReview__GradeCard
        authenticityToken
        submission
        gradeLabels
        evaluationCriteria
        passGrade
        reviewChecklist
        updateSubmissionCB={updateSubmission(
          ~feedackUpdate=false,
          ~submission,
          ~currentCoach,
          ~updateSubmissionCB,
        )}
      />
      <CoursesReview__ShowFeedback
        authenticityToken
        feedback={submission |> Submission.feedback}
        reviewed={submission |> Submission.grades |> ArrayUtils.isNotEmpty}
        submissionId={submission |> Submission.id}
        reviewChecklist
        updateSubmissionCB={updateSubmission(
          ~feedackUpdate=true,
          ~submission,
          ~currentCoach,
          ~updateSubmissionCB,
        )}
      />
    </div>
  </div>;

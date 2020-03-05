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
      ~feedbackUpdate,
      ~grades,
      ~passed,
      ~newFeedback,
      ~submission,
      ~currentCoach,
      ~updateSubmissionCB,
      ~checklist,
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
      ~createdAt=submission |> Submission.createdAt,
      ~passedAt,
      ~evaluatorName=
        if (feedbackUpdate) {
          submission |> Submission.evaluatorName;
        } else {
          Some(currentCoach |> Coach.name);
        },
      ~feedback,
      ~grades=newGrades,
      ~evaluatedAt,
      ~checklist,
    );
  updateSubmissionCB(feedbackUpdate, newSubmission);
};

[@react.component]
let make =
    (
      ~submission,
      ~teamSubmission,
      ~updateSubmissionCB,
      ~submissionNumber,
      ~currentCoach,
      ~evaluationCriteria,
      ~reviewChecklist,
      ~updateReviewChecklistCB,
      ~targetId,
      ~targetEvaluationCriteriaIds,
    ) =>
  <div
    ariaLabel={"submissions-overlay-card-" ++ (submission |> Submission.id)}
    className={cardClasses(submission)}>
    <div className="rounded-b-lg shadow">
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
      <CoursesReview__GradeCard
        submission
        teamSubmission
        evaluationCriteria
        targetEvaluationCriteriaIds
        reviewChecklist
        updateSubmissionCB={updateSubmission(
          ~feedbackUpdate=false,
          ~submission,
          ~currentCoach,
          ~updateSubmissionCB,
        )}
        updateReviewChecklistCB
        targetId
      />
      <CoursesReview__ShowFeedback
        feedback={submission |> Submission.feedback}
        reviewed={submission |> Submission.grades |> ArrayUtils.isNotEmpty}
        submissionId={submission |> Submission.id}
        reviewChecklist
        updateSubmissionCB={updateSubmission(
          ~feedbackUpdate=true,
          ~submission,
          ~currentCoach,
          ~updateSubmissionCB,
          ~checklist={submission |> Submission.checklist},
        )}
        updateReviewChecklistCB
        targetId
      />
    </div>
  </div>;

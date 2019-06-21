[@bs.config {jsx: 3}];

let str = React.string;

open CourseShow__Types;

let gradeBar = (gradeLabels, passGrade, evaluationCriteria, grade) => {
  let criterion =
    evaluationCriteria
    |> ListUtils.findOpt(c =>
         c |> EvaluationCriterion.id == (grade |> Grade.evaluationCriterionId)
       );

  switch (criterion) {
  | Some(criterion) =>
    let criterionId = criterion |> EvaluationCriterion.id;
    let criterionName = criterion |> EvaluationCriterion.name;
    let gradeNumber = grade |> Grade.grade;
    let grading =
      Grading.make(~criterionId, ~criterionName, ~grade=gradeNumber);

    <div key={gradeNumber |> string_of_int} className="mb-2">
      <GradeBar grading gradeLabels passGrade />
    </div>;
  | None => React.null
  };
};

let statusBar = (~color, ~text) => {
  let textColor = "text-" ++ color ++ "-500 ";
  let bgColor = "bg-" ++ color ++ "-100 ";

  <div
    className={
      "font-semibold p-2 py-4 flex w-full items-center justify-center "
      ++ textColor
      ++ bgColor
    }>
    <span className={"fa-stack text-lg mr-1 " ++ textColor}>
      <i className="fas fa-badge fa-stack-2x" />
      <i className="fas fa-check fa-stack-1x fa-inverse" />
    </span>
    {text |> str}
  </div>;
};

let submissionStatusIcon = (~passed) => {
  let text = passed ? "Passed" : "Failed";
  let color = passed ? "green" : "red";

  <div className="max-w-fc">
    <div
      className={
        "flex border-2 rounded-lg border-" ++ color ++ "-500 px-4 py-6"
      }>
      {
        passed ?
          <span className="fa-stack text-green-500 text-lg">
            <i className="fas fa-badge fa-stack-2x" />
            <i className="fas fa-check fa-stack-1x fa-inverse" />
          </span> :
          <i
            className="fas fa-exclamation-triangle text-3xl text-red-500 mx-1"
          />
      }
    </div>
    <div className={"text-center text-" ++ color ++ "-500 font-bold mt-2"}>
      {text |> str}
    </div>
  </div>;
};

let undoSubmissionCB = () => Webapi.Dom.(location |> Location.reload);

let gradingSection = (~grades, ~gradeBar, ~passed) =>
  <div>
    <div className="w-full md:hidden">
      {
        statusBar(
          ~color=passed ? "green" : "red",
          ~text=passed ? "Passed" : "Failed",
        )
      }
    </div>
    <div className="bg-white flex flex-wrap items-center py-4">
      <div
        className="w-full md:w-1/2 flex-shrink-0 justify-center hidden md:flex border-l px-6">
        {submissionStatusIcon(~passed)}
      </div>
      <div
        className="w-full md:w-1/2 flex-shrink-0 md:order-first px-4 md:px-6">
        <h5 className="pb-1 border-b"> {"Grading" |> str} </h5>
        <div className="mt-3">
          {
            grades
            |> List.map(grade => gradeBar(grade))
            |> Array.of_list
            |> React.array
          }
        </div>
      </div>
    </div>
  </div>;

let handleAddAnotherSubmission = (setShowSubmissionForm, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  setShowSubmissionForm(showSubmissionForm => !showSubmissionForm);
};

let submissions =
    (
      target,
      targetDetails,
      evaluationCriteria,
      gradeLabels,
      authenticityToken,
      coaches,
      userProfiles,
    ) => {
  let curriedGradeBar = gradeBar(gradeLabels, 2, evaluationCriteria);

  targetDetails
  |> TargetDetails.submissions
  |> List.sort((s1, s2) => {
       let s1CreatedAt = s1 |> Submission.createdAtDate;
       let s2CreatedAt = s2 |> Submission.createdAtDate;

       s1CreatedAt |> DateFns.differenceInSeconds(s2CreatedAt) |> int_of_float;
     })
  |> List.map(submission => {
       let attachments =
         targetDetails
         |> TargetDetails.submissionAttachments
         |> List.filter(a =>
              a
              |> SubmissionAttachment.submissionId
              == (submission |> Submission.id)
            );

       let grades =
         targetDetails |> TargetDetails.grades(submission |> Submission.id);

       <div key={submission |> Submission.id} className="mt-4">
         <div className="text-xs font-semibold">
           {
             "Submitted on "
             ++ (submission |> Submission.createdAtPretty)
             |> str
           }
         </div>
         <div
           className="mt-2 border-2 rounded-lg bg-gray-200 border-gray-200 shadow overflow-hidden">
           <div className="p-4 md:p-6 whitespace-pre-wrap">
             {submission |> Submission.description |> str}
             {
               attachments |> ListUtils.isEmpty ?
                 React.null :
                 <div className="mt-2">
                   <div className="text-xs font-semibold">
                     {"Attachments" |> str}
                   </div>
                   <CoursesShow__Attachments
                     removeAttachmentCB=None
                     attachments={
                       SubmissionAttachment.onlyAttachments(attachments)
                     }
                   />
                 </div>
             }
           </div>
           {
             switch (submission |> Submission.status) {
             | MarkedAsComplete =>
               statusBar(~color="green", ~text="Marked as complete")
             | Pending =>
               <div
                 className="bg-blue-100 px-6 py-4 flex justify-between items-center w-full">
                 <div
                   className="text-blue-500 font-bold flex items-center justify-center">
                   <span
                     className="fa-stack text-blue-500 text-lg mr-1 flex-shrink-0">
                     <i className="fas fa-circle fa-stack-2x" />
                     <i
                       className="fas fa-hourglass-half fa-stack-1x fa-inverse"
                     />
                   </span>
                   {"Review pending" |> str}
                 </div>
                 <CoursesShow__UndoButton
                   authenticityToken
                   undoSubmissionCB
                   targetId={target |> Target.id}
                 />
               </div>
             | Passed =>
               gradingSection(
                 ~grades,
                 ~passed=true,
                 ~gradeBar=curriedGradeBar,
               )
             | Failed =>
               gradingSection(
                 ~grades,
                 ~passed=false,
                 ~gradeBar=curriedGradeBar,
               )
             }
           }
           {
             targetDetails
             |> TargetDetails.feedback
             |> List.filter(feedback =>
                  feedback
                  |> Feedback.submissionId == (submission |> Submission.id)
                )
             |> List.map(feedback => {
                  let coach =
                    coaches
                    |> ListUtils.findOpt(c =>
                         c |> Coach.id == (feedback |> Feedback.coachId)
                       );

                  let userProfile =
                    switch (coach) {
                    | Some(coach) =>
                      userProfiles
                      |> ListUtils.findOpt(up =>
                           up |> UserProfile.userId == (coach |> Coach.userId)
                         )
                    | None => None
                    };

                  let (coachName, coachAvatar) =
                    switch (userProfile) {
                    | Some(userProfile) =>
                      let name = userProfile |> UserProfile.name;
                      let avatar = userProfile |> UserProfile.avatarUrl;
                      (
                        name,
                        <img className="w-10 h-10 rounded-full" src=avatar />,
                      );
                    | None => (
                        "Unknown Coach",
                        <div
                          className="w-10 h-10 rounded-full bg-gray-400 inline-block flex items-center justify-center">
                          <i className="fas fa-user-times" />
                        </div>,
                      )
                    };

                  <div
                    className="bg-white p-4 md:p-6 flex"
                    key={feedback |> Feedback.id}>
                    <div className="flex-shrink-0"> coachAvatar </div>
                    <div className="flex-grow ml-3">
                      <div className="text-sm">
                        {"Feedback from:" |> str}
                      </div>
                      <div className="font-semibold"> {coachName |> str} </div>
                      <div
                        className="mt-2"
                        dangerouslySetInnerHTML={
                          "__html": feedback |> Feedback.feedback,
                        }
                      />
                    </div>
                  </div>;
                })
             |> Array.of_list
             |> React.array
           }
         </div>
         <div
           className="text-center text-3xl mt-4 text-gray-600"
           dangerouslySetInnerHTML={
             "__html": "&middot;&nbsp;&middot;&nbsp;&middot",
           }
         />
       </div>;
     })
  |> Array.of_list
  |> React.array;
};

let addSubmission = (setShowSubmissionForm, addSubmissionCB, submission) => {
  setShowSubmissionForm(_ => false);
  addSubmissionCB(submission);
};

[@react.component]
let make =
    (
      ~targetDetails,
      ~target,
      ~authenticityToken,
      ~gradeLabels,
      ~evaluationCriteria,
      ~addSubmissionCB,
      ~targetStatus,
      ~coaches,
      ~userProfiles,
    ) => {
  let (showSubmissionForm, setShowSubmissionForm) =
    React.useState(() => false);

  <div>
    <div className="flex justify-between border-b pb-2">
      <h4> {"Your Submissions" |> str} </h4>
      {
        target |> Target.resubmittable && targetStatus |> TargetStatus.canSubmit ?
          <button
            className="btn btn-primary btn-small"
            onClick={handleAddAnotherSubmission(setShowSubmissionForm)}>
            <span className="hidden md:inline">
              {
                (showSubmissionForm ? "Cancel" : "Add another submission")
                |> str
              }
            </span>
            <span className="md:hidden"> {"Add another" |> str} </span>
          </button> :
          React.null
      }
    </div>
    {
      showSubmissionForm ?
        <CourseShow__SubmissionForm
          authenticityToken
          target
          addSubmissionCB={
            addSubmission(setShowSubmissionForm, addSubmissionCB)
          }
        /> :
        submissions(
          target,
          targetDetails,
          evaluationCriteria,
          gradeLabels,
          authenticityToken,
          coaches,
          userProfiles,
        )
    }
  </div>;
};

[@bs.config {jsx: 3}];

let str = React.string;

open CoursesCurriculum__Types;

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

    <div key={gradeNumber |> string_of_int} className="mb-4">
      <GradeBar grading gradeLabels passGrade />
    </div>;
  | None => React.null
  };
};

let statusBar = (~color, ~text) => {
  let textColor = "text-" ++ color ++ "-500 ";
  let bgColor = "bg-" ++ color ++ "-100 ";

  let icon =
    switch (color) {
    | "green" =>
      <span>
        <i className="fas fa-certificate fa-stack-2x" />
        <i className="fas fa-check fa-stack-1x fa-inverse" />
      </span>
    | _anyOtherColor =>
      <i className="fas fa-exclamation-triangle text-3xl text-red-500 mx-1" />
    };

  <div
    className={
      "font-semibold p-2 py-4 flex border-t border-b w-full items-center justify-center "
      ++ textColor
      ++ bgColor
    }>
    <span className={"fa-stack text-lg mr-1 " ++ textColor}> icon </span>
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
            <i className="fas fa-certificate fa-stack-2x" />
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
    <div className="bg-white flex border-t flex-wrap items-center py-4">
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
      targetStatus,
      targetDetails,
      evaluationCriteria,
      gradeLabels,
      authenticityToken,
      coaches,
      users,
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

       <div
         key={submission |> Submission.id}
         className="mt-4"
         ariaLabel={
           "Details about your submission on "
           ++ (submission |> Submission.createdAtPretty)
         }>
         <div className="text-xs font-semibold">
           {
             "Submitted on "
             ++ (submission |> Submission.createdAtPretty)
             |> str
           }
         </div>
         <div className="mt-2 rounded-lg bg-gray-100 shadow overflow-hidden">
           <div className="p-4 md:p-6">
             <MarkdownBlock
               profile=Markdown.Permissive
               markdown={submission |> Submission.description}
             />
             {
               attachments |> ListUtils.isEmpty ?
                 React.null :
                 <div className="mt-2">
                   <div className="text-xs font-semibold">
                     {"Attachments" |> str}
                   </div>
                   <CoursesCurriculum__Attachments
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
                 className="bg-white p-3 md:px-6 md:py-4 flex border-t justify-between items-center w-full">
                 <div
                   className="flex items-center justify-center font-semibold text-sm pl-2 pr-3 py-1 bg-orange-100 text-orange-600 rounded">
                   <span
                     className="fa-stack text-orange-400 mr-2 flex-shrink-0">
                     <i className="fas fa-circle fa-stack-2x" />
                     <i
                       className="fas fa-hourglass-half fa-stack-1x fa-inverse"
                     />
                   </span>
                   {"Review pending" |> str}
                 </div>
                 {
                   switch (targetStatus |> TargetStatus.status) {
                   | Submitted =>
                     <CoursesCurriculum__UndoButton
                       authenticityToken
                       undoSubmissionCB
                       targetId={target |> Target.id}
                     />

                   | Pending
                   | Passed
                   | Failed
                   | Locked(_) => React.null
                   }
                 }
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

                  let user =
                    switch (coach) {
                    | Some(coach) =>
                      users
                      |> ListUtils.findOpt(up =>
                           up |> User.id == (coach |> Coach.userId)
                         )
                    | None => None
                    };

                  let (coachName, coachTitle, coachAvatar) =
                    switch (user) {
                    | Some(user) =>
                      let name = user |> User.name;
                      let avatar = user |> User.avatarUrl;
                      let title = user |> User.title;
                      (
                        name,
                        title,
                        <img
                          className="w-12 h-12 rounded-full overflow-hidden object-cover border shadow"
                          src=avatar
                        />,
                      );
                    | None => (
                        "Unknown Coach",
                        None,
                        <div
                          className="w-10 h-10 rounded-full bg-gray-400 inline-block flex items-center justify-center">
                          <i className="fas fa-user-times" />
                        </div>,
                      )
                    };

                  <div
                    className="flex bg-white border-t p-4 md:p-6"
                    key={feedback |> Feedback.id}>
                    <div className="w-full">
                      <div className="flex items-center">
                        <div className="flex-shrink-0 mr-3"> coachAvatar </div>
                        <div>
                          <p className="text-xs">
                            {"Feedback from:" |> str}
                          </p>
                          <div className="flex flex-col">
                            <h4 className="text-sm md:text-base font-semibold">
                              {coachName |> str}
                            </h4>
                            {
                              switch (coachTitle) {
                              | Some(title) =>
                                <span className="text-xs">
                                  {title |> str}
                                </span>
                              | None => React.null
                              }
                            }
                          </div>
                        </div>
                      </div>
                      <MarkdownBlock
                        profile=Markdown.Permissive
                        className="md:ml-15"
                        markdown={feedback |> Feedback.feedback}
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
      ~users,
    ) => {
  let (showSubmissionForm, setShowSubmissionForm) =
    React.useState(() => false);

  <div>
    <div className="flex justify-between items-end border-b pb-2">
      <h4> {"Your Submissions" |> str} </h4>
      {
        targetStatus
        |> TargetStatus.canSubmit(
             ~resubmittable=target |> Target.resubmittable,
           ) ?
          <button
            className="btn btn-primary"
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
        <CoursesCurriculum__SubmissionForm
          authenticityToken
          target
          addSubmissionCB={
            addSubmission(setShowSubmissionForm, addSubmissionCB)
          }
        /> :
        submissions(
          target,
          targetStatus,
          targetDetails,
          evaluationCriteria,
          gradeLabels,
          authenticityToken,
          coaches,
          users,
        )
    }
  </div>;
};
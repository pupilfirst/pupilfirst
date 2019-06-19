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
    let grading =
      Grading.make(~criterionId, ~criterionName, ~grade=grade |> Grade.grade);
    <GradeBar grading gradeLabels passGrade />;
  | None => React.null
  };
};

let statusBar = (~color, ~text) => {
  let textColor = "text-" ++ color ++ "-500 ";
  let bgColor = "bg-" ++ color ++ "-100 ";

  <div
    className={
      "font-bold p-2 py-4 flex w-full items-center justify-center "
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
  <div className="bg-white flex flex-wrap items-center py-4">
    <div
      className="w-full md:w-1/2 flex-shrink-0 justify-center hidden md:flex border-l px-4">
      {submissionStatusIcon(~passed)}
    </div>
    <div className="w-full md:w-1/2 flex-shrink-0 md:order-first p-4">
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
  </div>;

[@react.component]
let make =
    (
      ~targetDetails,
      ~targetId,
      ~authenticityToken,
      ~gradeLabels,
      ~evaluationCriteria,
    ) => {
  let curriedGradeBar = gradeBar(gradeLabels, 2, evaluationCriteria);

  <div>
    <div className="flex justify-between border-b pb-2">
      <h4> {"Your Submissions" |> str} </h4>
      <button className="btn btn-primary btn-small">
        <span className="hidden md:inline">
          {"Add another submission" |> str}
        </span>
        <span className="md:hidden"> {"Add another" |> str} </span>
      </button>
    </div>
    {
      targetDetails
      |> TargetDetails.submissions
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
             targetDetails
             |> TargetDetails.grades(submission |> Submission.id);

           <div key={submission |> Submission.id} className="mt-4">
             <div className="text-xs font-bold">
               {
                 "Submitted on "
                 ++ (submission |> Submission.createdAtPretty)
                 |> str
               }
             </div>
             <div
               className="mt-2 border-2 rounded-lg bg-gray-200 border-gray-200 shadow">
               <div className="p-4 whitespace-pre-wrap">
                 {submission |> Submission.description |> str}
                 {
                   attachments |> ListUtils.isEmpty ?
                     React.null :
                     <div className="mt-2">
                       <div className="text-xs font-bold">
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
                       <span className="fa-stack text-blue-500 text-lg mr-1">
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
                       targetId
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
             </div>
           </div>;
         })
      |> Array.of_list
      |> React.array
    }
  </div>;
};

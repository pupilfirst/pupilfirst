[%bs.raw {|require("./CoursesReview__SubmissionOverlay.css")|}];

open CoursesReview__Types;
let str = React.string;

type state =
  | Loading
  | Loaded(SubmissionDetails.t);

module SubmissionDetailsQuery = [%graphql
  {|
    query($submissionId: ID!) {
      submissionDetails(submissionId: $submissionId) {
        targetId, targetTitle, levelNumber, levelId
        students {
          id
          name
        },
        evaluationCriteria{
          id, name, maxGrade, passGrade, gradeLabels { grade label}
        },
        reviewChecklist{
          title
          result{
            title
            feedback
          }
        },
        targetEvaluationCriteriaIds,
        submissions{
          id, evaluatorName, passedAt, createdAt, description, evaluatedAt
          attachments{
            url, title
          },
          grades {
            evaluationCriterionId, grade
          },
          feedback{
            id, coachName, coachAvatarUrl, coachTitle, createdAt,value
          },
        }
      }
    }
  |}
];

let updateSubmissionDetails = (setState, details) =>
  setState(_ => Loaded(details |> SubmissionDetails.decodeJS));

let getSubmissionDetails = (submissionId, setState, ()) => {
  setState(_ => Loading);
  SubmissionDetailsQuery.make(~submissionId, ())
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       response##submissionDetails |> updateSubmissionDetails(setState);
       Js.Promise.resolve();
     })
  |> ignore;

  None;
};

let closeOverlay = courseId =>
  ReasonReactRouter.push("/courses/" ++ courseId ++ "/review");

let headerSection = (submissionDetails, courseId) =>
  <div
    ariaLabel="submissions-overlay-header"
    className="bg-gray-100 border-b border-gray-300 px-3 pt-12 xl:pt-10 flex justify-center">
    <div
      className="relative bg-white border lg:border-transparent p-4 lg:px-6 lg:py-5 flex items-center justify-between rounded-lg shadow container max-w-3xl -mb-12">
      <div
        onClick={_ => closeOverlay(courseId)}
        className="review-submission-overlay__close flex flex-col items-center justify-center absolute rounded-t-lg lg:rounded-lg leading-tight px-4 py-1 h-8 lg:h-full cursor-pointer border border-b-0 border-gray-400 lg:border-0 lg:shadow lg:border-gray-300 bg-white text-gray-700 hover:text-gray-900 hover:bg-gray-100">
        <Icon className="if i-times-light text-xl lg:text-2xl mt-1 lg:mt-0" />
        <span className="text-xs hidden lg:inline-block mt-px">
          {"close" |> str}
        </span>
      </div>
      <div className="w-full md:w-5/6">
        <div className="block text-sm md:pr-2">
          <span
            className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
            {"Level "
             ++ (submissionDetails |> SubmissionDetails.levelNumber)
             |> str}
          </span>
          <a
            href={
              "/targets/" ++ (submissionDetails |> SubmissionDetails.targetId)
            }
            target="_blank"
            className="ml-2 font-semibold underline text-gray-900 hover:bg-primary-100 hover:text-primary-600 text-sm md:text-lg">
            {submissionDetails |> SubmissionDetails.targetTitle |> str}
          </a>
        </div>
        <div className="text-left mt-1 text-xs text-gray-800">
          <span> {"Submitted by " |> str} </span>
          {let studentCount =
             submissionDetails |> SubmissionDetails.students |> Array.length;

           submissionDetails
           |> SubmissionDetails.students
           |> Array.mapi((index, student) => {
                let commaRequired = index + 1 != studentCount;
                <span>
                  <a
                    className="font-semibold underline"
                    key={student |> Student.id}
                    href={"/students/" ++ (student |> Student.id) ++ "/report"}
                    target="_blank">
                    {student |> Student.name |> str}
                  </a>
                  {(commaRequired ? ", " : "") |> str}
                </span>;
              })
           |> React.array}
        </div>
      </div>
      <div
        className="hidden md:flex w-auto md:w-1/6 text-xs justify-end mt-2 md:mt-0">
        <a
          href={
            "/targets/" ++ (submissionDetails |> SubmissionDetails.targetId)
          }
          target="_blank"
          className="btn btn-primary-ghost btn-small hidden md:inline-block">
          {"View Target " |> str}
        </a>
      </div>
    </div>
  </div>;

let updateSubmission =
    (
      submissionDetails,
      setState,
      removePendingSubmissionCB,
      updateReviewedSubmissionCB,
      feedbackUpdate,
      submission,
    ) => {
  let newSubmissionDetails =
    SubmissionDetails.updateSubmission(submissionDetails, submission);
  setState(_ => Loaded(newSubmissionDetails));
  feedbackUpdate
    ? updateReviewedSubmissionCB(
        SubmissionDetails.makeSubmissionInfo(
          newSubmissionDetails,
          submission,
        ),
      )
    : removePendingSubmissionCB(submission |> Submission.id);
};

let updateReviewChecklist = (submissionDetails, setState, reviewChecklist) => {
  setState(_ =>
    Loaded(
      submissionDetails
      |> SubmissionDetails.updateReviewChecklist(reviewChecklist),
    )
  );
};

[@react.component]
let make =
    (
      ~courseId,
      ~submissionId,
      ~currentCoach,
      ~removePendingSubmissionCB,
      ~updateReviewedSubmissionCB,
    ) => {
  let (state, setState) = React.useState(() => Loading);

  React.useEffect(() => {
    ScrollLock.activate();
    Some(() => ScrollLock.deactivate());
  });

  React.useEffect1(
    getSubmissionDetails(submissionId, setState),
    [|submissionId|],
  );
  <div
    className="fixed z-30 top-0 left-0 w-full h-full overflow-y-scroll bg-white">
    {switch (state) {
     | Loaded(submissionDetails) =>
       <div>
         {headerSection(submissionDetails, courseId)}
         <div
           className="review-submission-overlay__submission-container relative container mx-auto mt-16 md:mt-18 max-w-3xl px-3 lg:px-0 pb-8">
           {submissionDetails
            |> SubmissionDetails.submissions
            |> Array.mapi((index, submission) =>
                 <CoursesReview__Submissions
                   key={index |> string_of_int}
                   submission
                   targetEvaluationCriteriaIds={
                     submissionDetails
                     |> SubmissionDetails.targetEvaluationCriteriaIds
                   }
                   updateSubmissionCB={updateSubmission(
                     submissionDetails,
                     setState,
                     removePendingSubmissionCB,
                     updateReviewedSubmissionCB,
                   )}
                   submissionNumber={
                     (
                       submissionDetails
                       |> SubmissionDetails.submissions
                       |> Array.length
                     )
                     - index
                   }
                   currentCoach
                   evaluationCriteria={
                     submissionDetails |> SubmissionDetails.evaluationCriteria
                   }
                   reviewChecklist={
                     submissionDetails |> SubmissionDetails.reviewChecklist
                   }
                   updateReviewChecklistCB={updateReviewChecklist(
                     submissionDetails,
                     setState,
                   )}
                   targetId={submissionDetails |> SubmissionDetails.targetId}
                 />
               )
            |> React.array}
         </div>
       </div>

     | Loading =>
       <div>
         <div className="bg-gray-100 py-4">
           <div className="max-w-3xl mx-auto"> {SkeletonLoading.card()} </div>
         </div>
         <div className="max-w-3xl mx-auto">
           {SkeletonLoading.heading()}
           {SkeletonLoading.paragraph()}
           {SkeletonLoading.profileCard()}
           {SkeletonLoading.paragraph()}
         </div>
       </div>
     }}
  </div>;
};

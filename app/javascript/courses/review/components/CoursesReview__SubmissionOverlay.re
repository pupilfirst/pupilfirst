[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__SubmissionOverlay.css")|}];

open CoursesReview__Types;
let str = React.string;

type state = {
  submissionDetails: option(SubmissionDetails.t),
  loading: bool,
};

module SubmissionDetailsQuery = [%graphql
  {|
    query($submissionId: ID!) {
      submissionDetails(submissionId: $submissionId) {
        targetId, targetTitle, userNames, levelNumber
        evaluationCriteria{
          id, name
        },
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
  setState(_ =>
    {
      loading: false,
      submissionDetails: Some(details |> SubmissionDetails.decodeJS),
    }
  );

let getSubmissionDetails = (authenticityToken, submissionId, setState, ()) => {
  setState(state => {...state, loading: true});
  SubmissionDetailsQuery.make(~submissionId, ())
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       response##submissionDetails |> updateSubmissionDetails(setState);
       Js.Promise.resolve();
     })
  |> ignore;

  None;
};

let headerSection = (submissionDetails, setSelectedSubmission) =>
  <div
    className="bg-gray-100 border-b border-gray-300 px-3 pt-12 xl:pt-10 flex justify-center">
    <div
      className="relative bg-white border lg:border-transparent p-4 lg:px-6 lg:py-5 flex items-center justify-between rounded-lg shadow container max-w-3xl -mb-12">
      <div
        onClick={_ => setSelectedSubmission(_ => None)}
        className="course-review-submission-overlay__close flex flex-col items-center justify-center absolute rounded-t-lg lg:rounded-lg leading-tight px-4 py-1 h-8 lg:h-full cursor-pointer border border-b-0 border-gray-400 lg:border-0 lg:shadow lg:border-gray-300 bg-white text-gray-700 hover:text-gray-900 hover:bg-gray-100">
        <Icon className="if i-times-light text-xl lg:text-2xl" />
        <span className="text-xs hidden lg:inline-block mt-px">
          {"close" |> str}
        </span>
      </div>
      <div className="w-full md:w-5/6">
        <div className="block text-sm md:pr-2">
          <span
            className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
            {"Level " ++ (submissionDetails |> SubmissionDetails.levelNumber) |> str}
          </span>
          <a
            href={"/targets/" ++ (submissionDetails |> SubmissionDetails.targetId)}
            target="_blank"
            className="ml-2 font-semibold underline text-gray-900 hover:bg-primary-100 hover:text-primary-600 text-sm md:text-lg">
            {submissionDetails |> SubmissionDetails.targetTitle |> str}
          </a>
        </div>
        <div className="text-left mt-1 text-xs text-gray-800">
          <span> {"Submitted by " |> str} </span>
          <span className="font-semibold">
            {submissionDetails |> SubmissionDetails.userNames |> str}
          </span>
        </div>
      </div>
      <div
        className="hidden md:flex w-auto md:w-1/6 text-xs justify-end mt-2 md:mt-0">
        <a
          href={"/targets/" ++ (submissionDetails |> SubmissionDetails.targetId)}
          target="_blank"
          className="btn btn-primary-ghost btn-small hidden md:inline-block">
          {"View Target " |> str}
        </a>
      </div>
    </div>
  </div>;
let updateSubmissionCB = (setState, removePendingSubmissionCB, submission) =>
  /* setState(state =>
       {
         ...state,
         submissionDetails:
           state.submissionDetails
           |> Js.Array.filter(s =>
                s |> SubmissionDetails.id != (submission |> SubmissionDetails.id)
              )
           |> Array.append([|submission|]),
       }
     ); */
  removePendingSubmissionCB(submission |> Submission.id);

[@react.component]
let make =
    (
      ~authenticityToken,
      ~levels,
      ~submissionId,
      ~setSelectedSubmission,
      ~gradeLabels,
      ~passGrade,
      ~currentCoach,
      ~removePendingSubmissionCB,
    ) => {
  let (state, setState) =
    React.useState(() => {loading: true, submissionDetails: None});

  React.useEffect(() => {
    ScrollLock.activate();
    Some(() => ScrollLock.deactivate());
  });

  React.useEffect1(
    getSubmissionDetails(authenticityToken, submissionId, setState),
    [|submissionId|],
  );
  switch (state.submissionDetails) {
  | Some(submissionDetails) =>
    <div
      className="fixed z-30 top-0 left-0 w-full h-full overflow-y-scroll bg-white">
      {headerSection(submissionDetails, setSelectedSubmission)}
      <div
        className="container mx-auto mt-16 md:mt-18 max-w-3xl px-3 lg:px-0 pb-8">
        {
          state.loading ?
            <div> {"Loading" |> str} </div> :
            submissionDetails
            |> SubmissionDetails.submissions
            |> Array.mapi((index, submission) =>
                 <div>
                   <CoursesReview__Submissions
                     key={index |> string_of_int}
                     authenticityToken
                     submission
                     gradeLabels
                     passGrade
                     updateSubmissionCB={
                       updateSubmissionCB(setState, removePendingSubmissionCB)
                     }
                     submissionNumber={
                       (
                         submissionDetails
                         |> SubmissionDetails.submissions
                         |> Array.length
                       )
                       - index
                     }
                     currentCoach
                     evaluationCriteria={submissionDetails |> SubmissionDetails.evaluationCriteria}
                   />
                 </div>
               )
            |> React.array
        }
      </div>
    </div>

  | None => React.null
  };
};

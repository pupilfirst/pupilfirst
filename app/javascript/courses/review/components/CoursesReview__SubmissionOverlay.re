[@bs.config {jsx: 3}];

open CoursesReview__Types;
let str = React.string;

type state = {
  submissionDetails: list(SubmissionDetails.t),
  loading: bool,
};

module ReviewSubmissionDetailsQuery = [%graphql
  {|
    query($submissionId: ID!) {
      reviewSubmissionDetails(submissionId: $submissionId) {
        id, failed, createdAt, description,
        attachments{
          url, title
        },
        grades {
          evaluationCriterionId, id, grade
        },
        feedback{
          id, coachId, createdAt,value
        }
      }
  }
|}
];

let updateSubmissionDetails = (setState, details) =>
  setState(_ =>
    {loading: false, submissionDetails: details |> SubmissionDetails.makeT}
  );

let getSubmissionDetails = (authenticityToken, submission, setState, ()) => {
  setState(state => {...state, loading: true});
  ReviewSubmissionDetailsQuery.make(
    ~submissionId=submission |> Submission.id,
    (),
  )
  |> GraphqlQuery.sendQuery(authenticityToken)
  |> Js.Promise.then_(response => {
       response##reviewSubmissionDetails |> updateSubmissionDetails(setState);
       Js.Promise.resolve();
     })
  |> ignore;

  None;
};

let levelNumber = (levels, levelId) =>
  "Level "
  ++ (
    levels
    |> ListUtils.unsafeFind(
         l => l |> Level.id == levelId,
         "Unable to find level with id "
         ++ levelId
         ++ "in CoursesReview__ShowSubmission",
       )
    |> Level.number
    |> string_of_int
  );

let headerSection = (submission, levels, setSelectedSubmission) =>
  <div
    className="bg-gray-100 border-b border-gray-400 px-3 pt-10 flex justify-center">
    <div
      onClick={_ => setSelectedSubmission(_ => None)}
      className="bg-white rounded-lg shadow mr-5 -mb-10 px-4 items-center flex flex-col justify-center hover:bg-gray-200 hover:text-primary-500 cursor-pointerr">
      <i className="fas fa-times text-xl" />
      {"Close" |> str}
    </div>
    <div
      className="bg-white border-t p-6 flex items-center justify-between rounded-lg shadow-md container max-w-3xl -mb-10">
      <div>
        <div className="flex items-center text-sm">
          <span className="bg-gray-400 py-px px-2 rounded-lg font-semibold">
            {submission |> Submission.levelId |> levelNumber(levels) |> str}
          </span>
          <span className="ml-2 font-semibold">
            {submission |> Submission.title |> str}
          </span>
        </div>
        <div className="text-left mt-1 text-xs text-gray-600">
          <span> {submission |> Submission.userNames |> str} </span>
          <span className="ml-2">
            {
              "Submitted on "
              ++ (submission |> Submission.createdAtPretty)
              |> str
            }
          </span>
        </div>
      </div>
      <div className="text-xs">
        {submission |> Submission.timeDistance |> str}
      </div>
    </div>
  </div>;

let showSubmissions = (authenticityToken, state) =>
  state.submissionDetails
  |> List.map(submission =>
       <div> <CoursesReview__Submissions authenticityToken submission /> </div>
     )
  |> Array.of_list
  |> React.array;

[@react.component]
let make = (~authenticityToken, ~levels, ~submission, ~setSelectedSubmission) => {
  let (state, setState) =
    React.useState(() => {loading: true, submissionDetails: []});

  React.useEffect(() => {
    ScrollLock.activate();
    Some(() => ScrollLock.deactivate());
  });

  React.useEffect1(
    getSubmissionDetails(authenticityToken, submission, setState),
    [|submission|],
  );
  <div
    className="fixed z-30 top-0 left-0 w-full h-full overflow-y-scroll bg-white">
    {headerSection(submission, levels, setSelectedSubmission)}
    <div
      className="container mx-auto mt-16 md:mt-18 max-w-3xl px-4 lg:px-0 pb-8">
      {
        state.loading ?
          <div> {"Loading" |> str} </div> :
          showSubmissions(authenticityToken, state)
      }
    </div>
  </div>;
};

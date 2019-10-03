[@bs.config {jsx: 3}];
[%bs.raw {|require("./CoursesReview__Root.css")|}];

open CoursesReview__Types;
let str = React.string;

type state = {
  submissions: array(SubmissionInfo.t),
  reviewedSubmissions: array(SubmissionInfo.t),
  showPending: bool,
  selectedLevel: option(Level.t),
  hasNextPage: bool,
  endCursor: option(string),
};

let openOverlay = submissionId =>
  ReasonReactRouter.push("/submissions/" ++ submissionId);

let onClickForLevelSelector = (level, setState, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  setState(state =>
    {
      ...state,
      selectedLevel: level,
      reviewedSubmissions: [||],
      hasNextPage: true,
      endCursor: None,
    }
  );
};

let dropDownButtonText = level =>
  "Level "
  ++ (level |> Level.number |> string_of_int)
  ++ " | "
  ++ (level |> Level.name);
let dropdownShowAllButton = (selectedLevel, setState) =>
  switch (selectedLevel) {
  | Some(_) => [|
      <button
        className="p-3 w-full text-left font-semibold focus:outline-none"
        onClick={onClickForLevelSelector(None, setState)}>
        {"All Levels" |> str}
      </button>,
    |]
  | None => [||]
  };

let showDropdown = (levels, selectedLevel, setState) => {
  let contents =
    dropdownShowAllButton(selectedLevel, setState)
    ->Array.append(
        levels
        |> Level.sort
        |> Array.map(level =>
             <button
               className="p-3 w-full text-left font-semibold focus:outline-none"
               onClick={onClickForLevelSelector(Some(level), setState)}>
               {dropDownButtonText(level) |> str}
             </button>
           ),
      );

  let selected =
    <button
      className="bg-white px-4 py-2 border border-gray-400 font-semibold rounded-lg focus:outline-none w-full md:w-auto flex justify-between">
      {
        (
          switch (selectedLevel) {
          | None => "All Levels"
          | Some(level) => dropDownButtonText(level)
          }
        )
        |> str
      }
      <span className="pl-2 ml-2 border-l">
        <i className="fas fa-chevron-down text-sm" />
      </span>
    </button>;

  <Dropdown selected contents right=true />;
};

let buttonClasses = selected =>
  "w-1/2 md:w-auto py-2 px-3 md:px-6 font-semibold text-sm focus:outline-none "
  ++ (
    selected ?
      "bg-primary-100 shadow-inner text-primary-500" :
      "bg-white shadow-md hover:shadow hover:text-primary-500 hover:bg-gray-100"
  );

let removePendingSubmission = (setState, submissionId) =>
  setState(state =>
    {
      ...state,
      submissions:
        state.submissions
        |> Js.Array.filter(s => s |> SubmissionInfo.id != submissionId),
      reviewedSubmissions: [||],
      hasNextPage: true,
      endCursor: None,
    }
  );

let updateReviewedSubmissions =
    (~setState, ~reviewedSubmissions, ~hasNextPage, ~endCursor) =>
  setState(state => {...state, reviewedSubmissions, hasNextPage, endCursor});

[@react.component]
let make =
    (
      ~authenticityToken,
      ~levels,
      ~submissions,
      ~gradeLabels,
      ~courseId,
      ~passGrade,
      ~currentCoach,
    ) => {
  let (state, setState) =
    React.useState(() =>
      {
        submissions,
        reviewedSubmissions: [||],
        showPending: true,
        selectedLevel: None,
        hasNextPage: true,
        endCursor: None,
      }
    );

  let url = ReasonReactRouter.useUrl();
  <div>
    {
      switch (url.path) {
      | ["submissions", submissionId, ..._] =>
        <CoursesReview__SubmissionOverlay
          authenticityToken
          courseId
          submissionId
          gradeLabels
          passGrade
          currentCoach
          removePendingSubmissionCB={removePendingSubmission(setState)}
        />
      | _ => React.null
      }
    }
    <div className="bg-gray-100 pt-12 pb-8 px-3 -mt-7">
      <div className="w-full bg-gray-100 relative md:sticky md:top-0">
        <div
          className="max-w-3xl mx-auto flex flex-col md:flex-row items-end lg:items-center justify-between pt-4 pb-4">
          <div
            className="course-review__status-tab w-full md:w-auto flex rounded-lg border border-gray-400">
            <button
              className={buttonClasses(state.showPending == true)}
              onClick={_ => setState(state => {...state, showPending: true})}>
              {"Pending" |> str}
              <span
                className="ml-2 text-white text-xs bg-red-500 w-5 h-5 inline-flex items-center justify-center rounded-full">
                {state.submissions |> Array.length |> string_of_int |> str}
              </span>
            </button>
            <button
              className={buttonClasses(state.showPending == false)}
              onClick={_ => setState(state => {...state, showPending: false})}>
              {"Reviewed" |> str}
            </button>
          </div>
          <div className="flex-shrink-0 pt-4 md:pt-0 w-full md:w-auto">
            {showDropdown(levels, state.selectedLevel, setState)}
          </div>
        </div>
      </div>
      <div className="max-w-3xl mx-auto">
        {
          state.showPending ?
            <CoursesReview__ShowPendingSubmissions
              authenticityToken
              submissions={state.submissions}
              levels
              selectedLevel={state.selectedLevel}
              openOverlayCB=openOverlay
            /> :
            <CoursesReview__ShowReviewedSubmissions
              authenticityToken
              courseId
              selectedLevel={state.selectedLevel}
              levels
              openOverlayCB=openOverlay
              reviewedSubmissions={state.reviewedSubmissions}
              endCursor={state.endCursor}
              hasNextPage={state.hasNextPage}
              updateReviewedSubmissionsCB={
                updateReviewedSubmissions(~setState)
              }
            />
        }
      </div>
    </div>
  </div>;
};

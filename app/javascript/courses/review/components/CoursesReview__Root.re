[%bs.raw {|require("./CoursesReview__Root.css")|}];

open CoursesReview__Types;
let str = React.string;

type visibleList =
  | PendingSubmissions
  | ReviewedSubmissions;

type state = {
  pendingSubmissions: array(SubmissionInfo.t),
  reviewedSubmissions: ReviewedSubmission.t,
  visibleList,
  selectedLevel: option(Level.t),
};

let openOverlay = (submissionId, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  ReasonReactRouter.push("/submissions/" ++ submissionId);
};

let updateLevel = (level, setState) => {
  setState(state =>
    {...state, selectedLevel: level, reviewedSubmissions: Unloaded}
  );
};

let onClickForLevelSelector = (level, selectedLevel, setState, event) => {
  event |> ReactEvent.Mouse.preventDefault;

  // Prevent state change when the level and selected level are the same
  switch (selectedLevel, level) {
  | (Some(sl), Some(l)) when l |> Level.id == (sl |> Level.id) => ()
  | _ => updateLevel(level, setState)
  };
};

let dropDownButtonText = level =>
  "Level "
  ++ (level |> Level.number |> string_of_int)
  ++ " | "
  ++ (level |> Level.name);

let dropdownElementClasses = (level, selectedLevel) => {
  "p-3 w-full text-left font-semibold focus:outline-none "
  ++ (
    switch (selectedLevel, level) {
    | (Some(sl), Some(l)) when l |> Level.id == (sl |> Level.id) => "bg-gray-200 text-primary-500"
    | (None, None) => "bg-gray-200 text-primary-500"
    | _ => ""
    }
  );
};

let showDropdown = (levels, selectedLevel, setState) => {
  let contents =
    [|
      <button
        className={dropdownElementClasses(None, selectedLevel)}
        onClick={onClickForLevelSelector(None, selectedLevel, setState)}>
        {"All Levels" |> str}
      </button>,
    |]
    ->Array.append(
        levels
        |> Level.sort
        |> Array.map(level =>
             <button
               className={dropdownElementClasses(Some(level), selectedLevel)}
               onClick={onClickForLevelSelector(
                 Some(level),
                 selectedLevel,
                 setState,
               )}>
               {dropDownButtonText(level) |> str}
             </button>
           ),
      );

  let selected =
    <button
      className="bg-white px-4 py-2 border border-gray-400 font-semibold rounded-lg focus:outline-none w-full md:w-auto flex justify-between">
      {(
         switch (selectedLevel) {
         | None => "All Levels"
         | Some(level) => dropDownButtonText(level)
         }
       )
       |> str}
      <span className="pl-2 ml-2 border-l">
        <i className="fas fa-chevron-down text-sm" />
      </span>
    </button>;

  <Dropdown selected contents right=true />;
};

let buttonClasses = selected =>
  "w-1/2 md:w-auto py-2 px-3 md:px-6 font-semibold text-sm focus:outline-none "
  ++ (
    selected
      ? "bg-primary-100 shadow-inner text-primary-500"
      : "bg-white shadow-md hover:shadow hover:text-primary-500 hover:bg-gray-100"
  );

let removePendingSubmission = (setState, submissionId) =>
  setState(state =>
    {
      ...state,
      pendingSubmissions:
        state.pendingSubmissions
        |> Js.Array.filter(s => s |> SubmissionInfo.id != submissionId),
      reviewedSubmissions: Unloaded,
    }
  );

let updateReviewedSubmissions =
    (~setState, ~reviewedSubmissions, ~hasNextPage, ~endCursor) =>
  setState(state =>
    {
      ...state,
      reviewedSubmissions:
        switch (hasNextPage, endCursor) {
        | (_, None)
        | (false, Some(_)) => FullyLoaded(reviewedSubmissions)
        | (true, Some(cursor)) =>
          PartiallyLoaded(reviewedSubmissions, cursor)
        },
    }
  );

let updateReviewedSubmission = (setState, submission) =>
  setState(state =>
    {
      ...state,
      reviewedSubmissions:
        switch (state.reviewedSubmissions) {
        | Unloaded => Unloaded
        | PartiallyLoaded(reviewedSubmissions, cursor) =>
          PartiallyLoaded(
            reviewedSubmissions |> SubmissionInfo.replace(submission),
            cursor,
          )
        | FullyLoaded(reviewedSubmissions) =>
          FullyLoaded(
            reviewedSubmissions |> SubmissionInfo.replace(submission),
          )
        },
    }
  );

[@react.component]
let make = (~levels, ~pendingSubmissions, ~courseId, ~currentCoach) => {
  let (state, setState) =
    React.useState(() =>
      {
        pendingSubmissions,
        reviewedSubmissions: Unloaded,
        visibleList: PendingSubmissions,
        selectedLevel: None,
      }
    );

  let url = ReasonReactRouter.useUrl();
  <div>
    {switch (url.path) {
     | ["submissions", submissionId, ..._] =>
       <CoursesReview__SubmissionOverlay
         courseId
         submissionId
         currentCoach
         removePendingSubmissionCB={removePendingSubmission(setState)}
         updateReviewedSubmissionCB={updateReviewedSubmission(setState)}
       />
     | _ => React.null
     }}
    <div className="bg-gray-100 pt-12 pb-8 px-3 -mt-7">
      <div className="w-full bg-gray-100 relative md:sticky md:top-0">
        <div
          className="max-w-3xl mx-auto flex flex-col md:flex-row items-end lg:items-center justify-between pt-4 pb-4">
          <div
            ariaLabel="status-tab"
            className="course-review__status-tab w-full md:w-auto flex rounded-lg border border-gray-400">
            <button
              className={buttonClasses(
                state.visibleList == PendingSubmissions,
              )}
              onClick={_ =>
                setState(state => {...state, visibleList: PendingSubmissions})
              }>
              {"Pending" |> str}
              <span
                className="ml-2 text-white text-xs bg-red-500 w-5 h-5 inline-flex items-center justify-center rounded-full">
                {state.pendingSubmissions
                 |> Array.length
                 |> string_of_int
                 |> str}
              </span>
            </button>
            <button
              className={buttonClasses(
                state.visibleList == ReviewedSubmissions,
              )}
              onClick={_ =>
                setState(state =>
                  {...state, visibleList: ReviewedSubmissions}
                )
              }>
              {"Reviewed" |> str}
            </button>
          </div>
          <div className="flex-shrink-0 pt-4 md:pt-0 w-full md:w-auto">
            {showDropdown(levels, state.selectedLevel, setState)}
          </div>
        </div>
      </div>
      <div className="max-w-3xl mx-auto">
        {switch (state.visibleList) {
         | PendingSubmissions =>
           <CoursesReview__ShowPendingSubmissions
             submissions={state.pendingSubmissions}
             levels
             selectedLevel={state.selectedLevel}
             openOverlayCB=openOverlay
           />
         | ReviewedSubmissions =>
           <CoursesReview__ShowReviewedSubmissions
             courseId
             selectedLevel={state.selectedLevel}
             levels
             openOverlayCB=openOverlay
             reviewedSubmissions={state.reviewedSubmissions}
             updateReviewedSubmissionsCB={updateReviewedSubmissions(
               ~setState,
             )}
           />
         }}
      </div>
    </div>
  </div>;
};

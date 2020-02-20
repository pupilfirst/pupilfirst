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
  showOnlyAssignedToMe: bool,
  filterString: string,
};

type action =
  | SelectLevel(Level.t)
  | DeselectLevel
  | RemovePendingSubmission(string)
  | SetReviewedSubmissions(array(SubmissionInfo.t), bool, option(string))
  | UpdateReviewedSubmission(SubmissionInfo.t)
  | SelectPendingTab
  | SelectReviewedTab
  | SelectAssignedToMe
  | DeselectAssignedToMe
  | UpdateFilterString(string);

let reducer = (state, action) =>
  switch (action) {
  | SelectLevel(level) => {
      ...state,
      selectedLevel: Some(level),
      reviewedSubmissions: Unloaded,
      filterString: "",
    }
  | DeselectLevel => {
      ...state,
      selectedLevel: None,
      reviewedSubmissions: Unloaded,
    }
  | RemovePendingSubmission(submissionId) => {
      ...state,
      pendingSubmissions:
        state.pendingSubmissions
        |> Js.Array.filter(s => s |> SubmissionInfo.id != submissionId),
      reviewedSubmissions: Unloaded,
    }
  | SetReviewedSubmissions(reviewedSubmissions, hasNextPage, endCursor) => {
      ...state,
      reviewedSubmissions:
        switch (hasNextPage, endCursor) {
        | (_, None)
        | (false, Some(_)) => FullyLoaded(reviewedSubmissions)
        | (true, Some(cursor)) =>
          PartiallyLoaded(reviewedSubmissions, cursor)
        },
    }
  | UpdateReviewedSubmission(submission) => {
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
  | SelectPendingTab => {...state, visibleList: PendingSubmissions}
  | SelectReviewedTab => {...state, visibleList: ReviewedSubmissions}
  | SelectAssignedToMe => {
      ...state,
      showOnlyAssignedToMe: true,
      filterString: "",
    }
  | DeselectAssignedToMe => {...state, showOnlyAssignedToMe: false}
  | UpdateFilterString(filterString) => {...state, filterString}
  };

let computeInitialState = pendingSubmissions => {
  pendingSubmissions,
  reviewedSubmissions: Unloaded,
  visibleList: PendingSubmissions,
  selectedLevel: None,
  showOnlyAssignedToMe: true,
  filterString: "",
};

let openOverlay = (submissionId, event) => {
  event |> ReactEvent.Mouse.preventDefault;
  ReasonReactRouter.push("/submissions/" ++ submissionId);
};

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

let buttonClasses = selected =>
  "w-1/2 md:w-auto py-2 px-3 md:px-6 font-semibold text-sm focus:outline-none "
  ++ (
    selected
      ? "bg-primary-100 shadow-inner text-primary-500"
      : "bg-white shadow-md hover:shadow hover:text-primary-500 hover:bg-gray-100"
  );

module Selectable = {
  type t =
    | Level(Level.t)
    | AssignedToMe;

  let label = t =>
    switch (t) {
    | Level(level) =>
      Some("Level " ++ (level |> Level.number |> string_of_int))
    | AssignedToMe => Some("From students")
    };

  let value = t =>
    switch (t) {
    | Level(level) => level |> Level.name
    | AssignedToMe => "Assigned to me"
    };

  let searchString = t =>
    switch (t) {
    | Level(level) =>
      "level "
      ++ (level |> Level.number |> string_of_int)
      ++ " "
      ++ (level |> Level.name)
    | AssignedToMe => "from students assigned to me"
    };

  let color = _t => "gray";
  let level = level => Level(level);
  let assignedToMe = () => AssignedToMe;
};

module Multiselect = MultiselectDropdown.Make(Selectable);

let unselected = (levels, state) => {
  let unselectedLevels =
    levels
    |> Js.Array.filter(level =>
         state.selectedLevel
         |> OptionUtils.mapWithDefault(
              selectedLevel =>
                level |> Level.id != (selectedLevel |> Level.id),
              true,
            )
       )
    |> Array.map(Selectable.level);

  state.showOnlyAssignedToMe
    ? unselectedLevels
    : unselectedLevels |> Array.append([|Selectable.assignedToMe()|]);
};

let selected = state => {
  let selectedLevel =
    state.selectedLevel
    |> OptionUtils.mapWithDefault(
         selectedLevel => [|Selectable.level(selectedLevel)|],
         [||],
       );

  state.showOnlyAssignedToMe
    ? selectedLevel |> Array.append([|Selectable.assignedToMe()|])
    : selectedLevel;
};

let onSelectFilter = (send, selectable) =>
  switch (selectable) {
  | Selectable.AssignedToMe => send(SelectAssignedToMe)
  | Level(level) => send(SelectLevel(level))
  };

let onDeselectFilter = (send, selectable) =>
  switch (selectable) {
  | Selectable.AssignedToMe => send(DeselectAssignedToMe)
  | Level(_) => send(DeselectLevel)
  };

let filterPlaceholder = state => {
  switch (state.selectedLevel, state.showOnlyAssignedToMe) {
  | (None, true) => "Filter by level"
  | (None, false) => "Filter by level, or only show submissions assigned to you"
  | (Some(_), true) => "Filter by another level"
  | (Some(_), false) => "Filter by another level, or only show submissions assigned to you"
  };
};

let restoreAssignedToMeFilter = (state, send) =>
  state.showOnlyAssignedToMe
    ? React.null
    : <div className="mt-2 text-xs italic">
        {"Now showing submissions from all students in this course. " |> str}
        <span
          className="underline cursor-pointer"
          onClick={_ => send(SelectAssignedToMe)}>
          {"Click here to only see submissions assigned to you." |> str}
        </span>
      </div>;

[@react.component]
let make = (~levels, ~pendingSubmissions, ~courseId, ~currentCoach) => {
  let (state, send) =
    React.useReducerWithMapState(
      reducer,
      pendingSubmissions,
      computeInitialState,
    );
  let url = ReasonReactRouter.useUrl();
  <div>
    {switch (url.path) {
     | ["submissions", submissionId, ..._] =>
       <CoursesReview__SubmissionOverlay
         courseId
         submissionId
         currentCoach
         removePendingSubmissionCB={submissionId =>
           send(RemovePendingSubmission(submissionId))
         }
         updateReviewedSubmissionCB={submission =>
           send(UpdateReviewedSubmission(submission))
         }
       />
     | _ => React.null
     }}
    <div className="bg-gray-100 pt-12 pb-8 px-3 -mt-7">
      <div className="max-w-3xl mx-auto bg-gray-100 sticky md:static md:top-0">
        <div
          className="flex flex-col md:flex-row items-end lg:items-center justify-center pt-4 pb-4">
          <div
            ariaLabel="status-tab"
            className="course-review__status-tab w-full md:w-auto flex rounded-lg border border-gray-400">
            <button
              className={buttonClasses(
                state.visibleList == PendingSubmissions,
              )}
              onClick={_ => send(SelectPendingTab)}>
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
              onClick={_ => send(SelectReviewedTab)}>
              {"Reviewed" |> str}
            </button>
          </div>
        </div>
        <Multiselect
          unselected={unselected(levels, state)}
          selected={selected(state)}
          onSelect={onSelectFilter(send)}
          onDeselect={onDeselectFilter(send)}
          value={state.filterString}
          onChange={filterString => send(UpdateFilterString(filterString))}
          placeholder={filterPlaceholder(state)}
        />
        {restoreAssignedToMeFilter(state, send)}
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
             updateReviewedSubmissionsCB={(
               ~reviewedSubmissions,
               ~hasNextPage,
               ~endCursor,
             ) =>
               send(
                 SetReviewedSubmissions(
                   reviewedSubmissions,
                   hasNextPage,
                   endCursor,
                 ),
               )
             }
           />
         }}
      </div>
    </div>
  </div>;
};

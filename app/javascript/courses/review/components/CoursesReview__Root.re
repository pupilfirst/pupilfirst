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
  selectedCoach: option(Coach.t),
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
  | SelectCoach(Coach.t)
  | DeselectCoach
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
  | SelectCoach(coach) => {
      ...state,
      selectedCoach: Some(coach),
      filterString: "",
    }
  | DeselectCoach => {...state, selectedCoach: None}
  | UpdateFilterString(filterString) => {...state, filterString}
  };

let computeInitialState =
    ((pendingSubmissions, teamCoaches, currentTeamCoach)) => {
  pendingSubmissions,
  reviewedSubmissions: Unloaded,
  visibleList: PendingSubmissions,
  selectedLevel: None,
  selectedCoach: currentTeamCoach,

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
    | AssignedToCoach(Coach.t, string);

  let label = t =>
    switch (t) {
    | Level(level) =>
      Some("Level " ++ (level |> Level.number |> string_of_int))
    | AssignedToCoach(_) => Some("From students")
    };

  let value = t =>
    switch (t) {
    | Level(level) => level |> Level.name
    | AssignedToCoach(coach, currentCoachId) =>
      let name =
        coach |> Coach.id == currentCoachId ? "Me" : coach |> Coach.name;
      "Assigned to " ++ name;
    };

  let searchString = t =>
    switch (t) {
    | Level(level) =>
      "level "
      ++ (level |> Level.number |> string_of_int)
      ++ " "
      ++ (level |> Level.name)
    | AssignedToCoach(coach, currentCoachId) =>
      let addMe = coach |> Coach.id == currentCoachId ? "me" : "";
      addMe ++ " from students assigned to " ++ (coach |> Coach.name);
    };

  let color = _t => "gray";
  let level = level => Level(level);
  let assignedToCoach = (coach, currentCoachId) =>
    AssignedToCoach(coach, currentCoachId);
};

module Multiselect = MultiselectDropdown.Make(Selectable);

let unselected = (levels, coaches, currentCoachId, state) => {
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

  let unselectedCoaches =
    coaches
    |> Js.Array.filter(coach =>
         state.selectedCoach
         |> OptionUtils.mapWithDefault(
              selectedCoach => coach |> Coach.id != Coach.id(selectedCoach),
              true,
            )
       )
    |> Array.map(coach => Selectable.assignedToCoach(coach, currentCoachId));

  unselectedLevels |> Array.append(unselectedCoaches);
};

let selected = (state, currentCoachId) => {
  let selectedLevel =
    state.selectedLevel
    |> OptionUtils.mapWithDefault(
         selectedLevel => [|Selectable.level(selectedLevel)|],
         [||],
       );

  let selectedCoach =
    state.selectedCoach
    |> OptionUtils.mapWithDefault(
         selectedCoach => {
           [|Selectable.assignedToCoach(selectedCoach, currentCoachId)|]
         },
         [||],
       );

  selectedLevel |> Array.append(selectedCoach);
};

let onSelectFilter = (send, selectable) =>
  switch (selectable) {
  | Selectable.AssignedToCoach(coach, _currentCoachId) =>
    send(SelectCoach(coach))
  | Level(level) => send(SelectLevel(level))
  };

let onDeselectFilter = (send, selectable) =>
  switch (selectable) {
  | Selectable.AssignedToCoach(_) => send(DeselectCoach)
  | Level(_) => send(DeselectLevel)
  };

let filterPlaceholder = state => {
  switch (state.selectedLevel, state.selectedCoach) {
  | (None, Some(_)) => "Filter by level"
  | (None, None) => "Filter by level, or only show submissions assigned to a coach"
  | (Some(_), Some(_)) => "Filter by another level"
  | (Some(_), None) => "Filter by another level, or only show submissions assigned to a coach"
  };
};

let restoreAssignedToMeFilter = (state, send, currentTeamCoach) =>
  switch (state.selectedCoach, currentTeamCoach) {
  | (None, Some(currentCoach)) =>
    <div className="mt-2 text-xs italic">
      {"Now showing submissions from all students in this course. " |> str}
      <span
        className="underline cursor-pointer"
        onClick={_ => send(SelectCoach(currentCoach))}>
        {"Click here to only see submissions assigned to you." |> str}
      </span>
    </div>
  | (Some(selectedCoach), Some(currentCoach))
      when selectedCoach |> Coach.id != (currentCoach |> Coach.id) =>
    <div className="mt-2 text-xs italic">
      {"Now showing submissions assigned to "
       ++ (selectedCoach |> Coach.name)
       ++ ". "
       |> str}
      <span
        className="underline cursor-pointer"
        onClick={_ => send(SelectCoach(currentCoach))}>
        {"Click here to only see submissions assigned to you." |> str}
      </span>
    </div>
  | (Some(_), Some(_))
  | (_, None) => React.null
  };

[@react.component]
let make =
    (~levels, ~pendingSubmissions, ~courseId, ~teamCoaches, ~currentCoach) => {
  let currentTeamCoach =
    teamCoaches->Belt.Array.some(coach =>
      coach |> Coach.id == (currentCoach |> Coach.id)
    )
      ? Some(currentCoach) : None;
  let (state, send) =
    React.useReducerWithMapState(
      reducer,
      (pendingSubmissions, teamCoaches, currentTeamCoach),
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
                className="course-review__status-tab-badge ml-2 text-white text-xs bg-red-500 w-auto h-5 px-1 inline-flex items-center justify-center rounded-full">
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
          unselected={unselected(
            levels,
            teamCoaches,
            currentCoach |> Coach.id,
            state,
          )}
          selected={selected(state, currentCoach |> Coach.id)}
          onSelect={onSelectFilter(send)}
          onDeselect={onDeselectFilter(send)}
          value={state.filterString}
          onChange={filterString => send(UpdateFilterString(filterString))}
          placeholder={filterPlaceholder(state)}
        />
        {restoreAssignedToMeFilter(state, send, currentTeamCoach)}
      </div>
      <div className="max-w-3xl mx-auto">
        {switch (state.visibleList) {
         | PendingSubmissions =>
           <CoursesReview__ShowPendingSubmissions
             submissions={state.pendingSubmissions}
             levels
             selectedLevel={state.selectedLevel}
           />
         | ReviewedSubmissions =>
           <CoursesReview__ShowReviewedSubmissions
             courseId
             selectedLevel={state.selectedLevel}
             levels
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

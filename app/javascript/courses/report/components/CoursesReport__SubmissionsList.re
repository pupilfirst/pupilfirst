open CoursesReport__Types;
let str = React.string;

type targetStatus = [ | `Submitted | `Failed | `Passed];

type sortDirection = [ | `Ascending | `Descending];

type sortBy = {
  criterion: string,
  criterionType: [ | `String | `Number],
};

let sortBy = {criterion: "Submitted At", criterionType: `Number};

type loading =
  | Loaded
  | Reloading
  | LoadingMore;

type filter = {
  selectedLevel: option(Level.t),
  selectedStatus: option(targetStatus),
};

type state = {
  loading,
  filterString: string,
};

type action =
  | UpdateFilterString(string)
  | BeginLoadingMore
  | BeginReloading
  | CompletedLoading;

let statusString = targetStatus => {
  switch (targetStatus) {
  | `Submitted => "Submitted"
  | `Failed => "Failed"
  | `Passed => "Passed"
  };
};

module StudentSubmissionsQuery = [%graphql
  {|
   query StudentsReportSubmissionsQuery($studentId: ID!, $after: String, $status: SubmissionReviewStatus, $levelId: ID, $sortDirection: SortDirection!) {
    studentSubmissions(studentId: $studentId, after: $after, first: 20 , status: $status, levelId: $levelId, sortDirection: $sortDirection) {
       nodes {
        id
        createdAt
        levelId
        targetId
        passedAt
        title
        evaluatorId
        studentIds
        teamTarget
       }
       pageInfo {
         hasNextPage
         endCursor
       }
      }
    }
   |}
];

module Selectable = {
  type t =
    | Level(Level.t)
    | TargetStatus(targetStatus);

  let label = t =>
    switch (t) {
    | Level(level) =>
      Some("Level " ++ (level |> Level.number |> string_of_int))
    | TargetStatus(_targetStatus) => Some("Status")
    };

  let value = t =>
    switch (t) {
    | Level(level) => level |> Level.name
    | TargetStatus(targetStatus) => statusString(targetStatus)
    };

  let searchString = t =>
    switch (t) {
    | Level(level) =>
      "level "
      ++ (level |> Level.number |> string_of_int)
      ++ " "
      ++ (level |> Level.name)
    | TargetStatus(targetStatus) => "status " ++ statusString(targetStatus)
    };

  let color = t =>
    switch (t) {
    | Level(_level) => "gray"
    | TargetStatus(status) =>
      switch (status) {
      | `Submitted => "blue"
      | `Passed => "green"
      | `Failed => "red"
      }
    };
  let level = level => Level(level);
  let targetStatus = targetStatus => TargetStatus(targetStatus);
};

module Multiselect = MultiselectDropdown.Make(Selectable);

let unselected = (levels, selectedLevel, selectedStatus) => {
  let unselectedLevels =
    levels
    |> Js.Array.filter(level => Level.number(level) != 0)
    |> Js.Array.filter(level =>
         selectedLevel
         |> OptionUtils.mapWithDefault(
              selectedLevel =>
                level |> Level.id != (selectedLevel |> Level.id),
              true,
            )
       )
    |> Array.map(Selectable.level);

  let unselectedStatus =
    [|`Submitted, `Failed, `Passed|]
    |> Js.Array.filter(status =>
         selectedStatus
         |> OptionUtils.mapWithDefault(
              selectedStatus => status != selectedStatus,
              true,
            )
       )
    |> Array.map(Selectable.targetStatus);

  unselectedLevels |> Array.append(unselectedStatus);
};

let selected = (selectedLevel, selectedStatus) => {
  let selectedLevel =
    selectedLevel
    |> OptionUtils.mapWithDefault(
         selectedLevel => [|Selectable.level(selectedLevel)|],
         [||],
       );

  let selectedStatus =
    selectedStatus
    |> OptionUtils.mapWithDefault(
         selectedStatus => {[|Selectable.targetStatus(selectedStatus)|]},
         [||],
       );

  selectedLevel |> Array.append(selectedStatus);
};

let onSelectFilter =
    (send, updateSelectedLevelCB, updateSelectedStatusCB, selectable) => {
  send(UpdateFilterString(""));
  switch (selectable) {
  | Selectable.TargetStatus(status) => updateSelectedStatusCB(Some(status))
  | Level(level) => updateSelectedLevelCB(Some(level))
  };
};

let onDeselectFilter =
    (updateSelectedLevelCB, updateSelectedStatusCB, selectable) =>
  switch (selectable) {
  | Selectable.TargetStatus(_status) => updateSelectedStatusCB(None)
  | Level(_level) => updateSelectedLevelCB(None)
  };

module Sortable = {
  type t = sortBy;

  let criterion = t => t.criterion;
  let criterionType = t => t.criterionType;
};

module SubmissionsSorter = Sorter.Make(Sortable);

let submissionsSorter = (sortDirection, updateSortDirectionCB) => {
  let criteria = [|sortBy|];
  <div
    ariaLabel="Change submissions sorting"
    className="flex-shrink-0 mt-3 md:mt-0 md:ml-2">
    <label className="block text-tiny font-semibold uppercase">
      {"Sort by:" |> str}
    </label>
    <SubmissionsSorter
      criteria
      selectedCriterion=sortBy
      direction=sortDirection
      onDirectionChange={sortDirection => {
        updateSortDirectionCB(sortDirection)
      }}
      onCriterionChange={_ => ()}
    />
  </div>;
};

let filterPlaceholder = (selectedLevel, selectedStatus) => {
  switch (selectedLevel, selectedStatus) {
  | (None, Some(_)) => "Filter by level"
  | (None, None) => "Filter by level, or by status"
  | (Some(_), Some(_)) => "Filter by another level"
  | (Some(_), None) => "Filter by another level, or by status"
  };
};

let reducer = (state, action) => {
  switch (action) {
  | UpdateFilterString(filterString) => {...state, filterString}
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | BeginReloading => {...state, loading: Reloading}
  | CompletedLoading => {...state, loading: Loaded}
  };
};

let updateStudentSubmissions =
    (
      send,
      updateSubmissionsCB,
      endCursor,
      hasNextPage,
      submissions,
      selectedLevel,
      selectedStatus,
      sortDirection,
      nodes,
    ) => {
  let updatedSubmissions =
    Array.append(
      (
        switch (nodes) {
        | None => [||]
        | Some(submissionsArray) => submissionsArray |> Submission.makeFromJs
        }
      )
      |> ArrayUtils.flatten,
      submissions,
    );

  let filter = Submissions.makeFilter(selectedLevel, selectedStatus);

  let submissionsData =
    Submissions.make(
      ~submissions=updatedSubmissions,
      ~filter,
      ~sortDirection,
    );

  let submissionsData: Submissions.t =
    switch (hasNextPage, endCursor) {
    | (true, None)
    | (false, _) => FullyLoaded(submissionsData)
    | (true, Some(cursor)) => PartiallyLoaded(submissionsData, cursor)
    };

  updateSubmissionsCB(submissionsData);
  send(CompletedLoading);
};

let getStudentSubmissions =
    (
      studentId,
      cursor,
      send,
      level,
      status,
      sortDirection,
      submissions,
      updateSubmissionsCB,
    ) => {
  let levelId = level->Belt.Option.flatMap(level => Some(Level.id(level)));
  let status = status->Belt.Option.flatMap(status => Some(status));
  (
    switch (cursor) {
    | Some(cursor) =>
      StudentSubmissionsQuery.make(
        ~studentId,
        ~after=cursor,
        ~sortDirection,
        ~levelId?,
        ~status?,
        (),
      )
    | None =>
      StudentSubmissionsQuery.make(
        ~studentId,
        ~sortDirection,
        ~levelId?,
        ~status?,
        (),
      )
    }
  )
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
       response##studentSubmissions##nodes
       |> updateStudentSubmissions(
            send,
            updateSubmissionsCB,
            response##studentSubmissions##pageInfo##endCursor,
            response##studentSubmissions##pageInfo##hasNextPage,
            submissions,
            level,
            status,
            sortDirection,
          );
       Js.Promise.resolve();
     })
  |> ignore;
};

let showSubmissionStatus = submission =>
  switch (submission |> Submission.status) {
  | `Failed =>
    <div
      className="bg-red-100 border border-red-500 flex-shrink-0 leading-normal text-red-800 font-semibold px-3 py-px rounded">
      {"Failed" |> str}
    </div>

  | `Passed =>
    <div
      className="bg-green-100 border border-green-500 flex-shrink-0 leading-normal text-green-800 font-semibold px-3 py-px rounded">
      {"Passed" |> str}
    </div>

  | `Submitted =>
    <div
      className="bg-blue-100 border border-blue-500 flex-shrink-0 leading-normal text-blue-800 font-semibold px-3 py-px rounded">
      {"Submitted" |> str}
    </div>
  };

let submissionCardClasses = submission =>
  "flex flex-col md:flex-row items-start md:items-center justify-between bg-white border-l-3 p-3 md:py-6 md:px-5 mt-4 cursor-pointer rounded-r-lg shadow hover:border-primary-500 hover:text-primary-500 hover:shadow-md "
  ++ (
    switch (submission |> Submission.status) {
    | `Failed => "border-red-500"
    | `Passed => "border-green-500"
    | `Submitted => "border-blue-500"
    }
  );

let showSubmission = (submissions, levels, teamStudentIds) =>
  <div>
    {submissions
     |> Array.map(submission =>
          <div
            key={submission |> Submission.id}
            ariaLabel={"student-submission-" ++ (submission |> Submission.id)}>
            <a
              className="block relative z-10"
              href={"/targets/" ++ (submission |> Submission.targetId)}
              target="_blank">
              <div
                key={submission |> Submission.id}
                ariaLabel={
                  "student-submission-card-" ++ (submission |> Submission.id)
                }
                className={submissionCardClasses(submission)}>
                <div className="w-full md:w-3/4">
                  <div className="block text-sm md:pr-2">
                    <span
                      className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
                      {submission
                       |> Submission.levelId
                       |> Level.levelLabel(levels)
                       |> str}
                    </span>
                    <span className="ml-2 font-semibold text-base">
                      {submission |> Submission.title |> str}
                    </span>
                  </div>
                  <div className="mt-1 ml-px text-xs text-gray-900">
                    <span className="ml-1">
                      {"Submitted on "
                       ++ (submission |> Submission.createdAtPretty)
                       |> str}
                    </span>
                  </div>
                </div>
                {<div
                   className="w-auto md:w-1/4 text-xs flex justify-end mt-2 md:mt-0">
                   {showSubmissionStatus(submission)}
                 </div>}
              </div>
            </a>
            {switch (submission |> Submission.targetRole) {
             | Student => React.null
             | Team(studentIds) =>
               teamStudentIds == studentIds
                 ? React.null
                 : <div
                     ariaLabel={
                       "Team change notice for submission "
                       ++ Submission.id(submission)
                     }
                     className="w-full text-xs rounded-b bg-indigo-100 text-indigo-700 px-4 pt-3 pb-2 -mt-1 flex flex-1 justify-between items-center">
                     <div
                       className="flex flex-1 justify-start items-start pr-8">
                       <FaIcon
                         classes="fas fa-exclamation-triangle text-sm md:text-base mt-1"
                       />
                       <div className="inline-block pl-3">
                         {"This submission is not considered towards its target's completion; it was a "
                          |> str}
                         <span className="italic"> {"team" |> str} </span>
                         {" target, and your team changed after you made this submission."
                          |> str}
                       </div>
                     </div>
                     <a
                       href={"/submissions/" ++ Submission.id(submission)}
                       className="flex-shrink-0 px-2 py-1 text-xs font-semibold text-indigo-700 hover:bg-indigo-200 hover:text-indigo-800 rounded">
                       <span className="hidden md:inline">
                         {"View Submission" |> str}
                       </span>
                       <FaIcon classes="fas fa-arrow-right ml-2" />
                     </a>
                   </div>
             }}
          </div>
        )
     |> React.array}
  </div>;

let showSubmissions = (submissions, levels, teamStudentIds) =>
  submissions |> ArrayUtils.isEmpty
    ? <div
        className="course-review__reviewed-empty text-lg font-semibold text-center py-4">
        <h5 className="py-4 mt-4 bg-gray-200 text-gray-800 font-semibold">
          {"No submissions to show " |> str}
        </h5>
      </div>
    : showSubmission(submissions, levels, teamStudentIds);

[@react.component]
let make =
    (
      ~studentId,
      ~levels,
      ~submissions,
      ~updateSubmissionsCB,
      ~teamStudentIds,
      ~selectedLevel,
      ~selectedStatus,
      ~sortDirection,
      ~updateSelectedLevelCB,
      ~updateSelectedStatusCB,
      ~updateSortDirectionCB,
    ) => {
  let (state, send) =
    React.useReducer(reducer, {filterString: "", loading: Loaded});

  React.useEffect3(
    () => {
      if (submissions
          |> Submissions.needsReloading(
               selectedLevel,
               selectedStatus,
               sortDirection,
             )) {
        send(BeginReloading);
        getStudentSubmissions(
          studentId,
          None,
          send,
          selectedLevel,
          selectedStatus,
          sortDirection,
          [||],
          updateSubmissionsCB,
        );
      };

      None;
    },
    (selectedLevel, selectedStatus, sortDirection),
  );
  <div className="max-w-3xl mx-auto">
    {<div className="md:flex w-full items-start pb-4">
       <div className="flex-1">
         <label className="block text-tiny font-semibold uppercase">
           {"Filter by:" |> str}
         </label>
         <Multiselect
           id="filter"
           unselected={unselected(levels, selectedLevel, selectedStatus)}
           selected={selected(selectedLevel, selectedStatus)}
           onSelect={onSelectFilter(
             send,
             updateSelectedLevelCB,
             updateSelectedStatusCB,
           )}
           onDeselect={onDeselectFilter(
             updateSelectedLevelCB,
             updateSelectedStatusCB,
           )}
           value={state.filterString}
           onChange={filterString => send(UpdateFilterString(filterString))}
           placeholder={filterPlaceholder(selectedLevel, selectedStatus)}
         />
       </div>
       {submissionsSorter(sortDirection, updateSortDirectionCB)}
     </div>}
    <div ariaLabel="student-submissions">
      {switch ((submissions: Submissions.t)) {
       | Unloaded =>
         SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.card())
       | PartiallyLoaded({submissions}, cursor) =>
         <div>
           {showSubmissions(submissions, levels, teamStudentIds)}
           {switch (state.loading) {
            | Loaded =>
              <button
                className="btn btn-primary-ghost cursor-pointer w-full mt-4"
                onClick={_ => {
                  send(BeginLoadingMore);
                  getStudentSubmissions(
                    studentId,
                    Some(cursor),
                    send,
                    selectedLevel,
                    selectedStatus,
                    sortDirection,
                    submissions,
                    updateSubmissionsCB,
                  );
                }}>
                {"Load More..." |> str}
              </button>
            | LoadingMore =>
              SkeletonLoading.multiple(
                ~count=3,
                ~element=SkeletonLoading.card(),
              )
            | Reloading => React.null
            }}
         </div>
       | FullyLoaded({submissions}) =>
         showSubmissions(submissions, levels, teamStudentIds)
       }}
    </div>
    {switch (submissions) {
     | Unloaded => React.null

     | _ =>
       let loading =
         switch (state.loading) {
         | Loaded => false
         | Reloading => true
         | LoadingMore => false
         };
       <LoadingSpinner loading />;
     }}
  </div>;
};

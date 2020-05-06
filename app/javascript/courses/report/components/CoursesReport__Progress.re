open CoursesReport__Types;
let str = React.string;

type targetStatus = [ | `Pending | `Failed | `Passed];

type sortDirection = [ | `Ascending | `Descending];

type sortBy = {
  criterion: string,
  criterionType: [ | `String | `Number],
};

type loading =
  | Loaded
  | Reloading
  | LoadingMore;

type filter = {
  selectedLevel: option(Level.t),
  selectedStatus: option(targetStatus),
};

type state = {
  filter,
  sortBy,
  sortDirection,
  loading,
  filterString: string,
};

type action =
  | SelectLevel(Level.t)
  | DeselectLevel
  | SelectStatus(targetStatus)
  | DeselectStatus
  | UpdateSortDirection(sortDirection)
  | UpdateFilterString(string)
  | BeginLoadingMore
  | BeginReloading
  | CompletedLoading;

let statusString = targetStatus => {
  switch (targetStatus) {
  | `Pending => "Submitted"
  | `Failed => "Failed"
  | `Passed => "Passed"
  };
};

module StudentSubmissionsQuery = [%graphql
  {|
   query StudentsReportSubmissionsQuery($studentId: ID!, $after: String, $status: SubmissionReviewResult, $levelId: ID, $sortDirection: SortDirection!) {
    studentSubmissions(studentId: $studentId, after: $after, first: 20 , status: $status, levelId: $levelId, sortDirection: $sortDirection) {
       nodes {
         id
        createdAt
        levelId
        passedAt
        title
        evaluatorId
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
      | `Pending => "blue"
      | `Passed => "green"
      | `Failed => "red"
      }
    };
  let level = level => Level(level);
  let targetStatus = targetStatus => TargetStatus(targetStatus);
};

module Multiselect = MultiselectDropdown.Make(Selectable);

let unselected = (levels, filter) => {
  let unselectedLevels =
    levels
    |> Js.Array.filter(level =>
         filter.selectedLevel
         |> OptionUtils.mapWithDefault(
              selectedLevel =>
                level |> Level.id != (selectedLevel |> Level.id),
              true,
            )
       )
    |> Array.map(Selectable.level);

  let unselectedStatus =
    [|`Pending, `Failed, `Passed|]
    |> Js.Array.filter(status =>
         filter.selectedStatus
         |> OptionUtils.mapWithDefault(
              selectedStatus => status == selectedStatus,
              true,
            )
       )
    |> Array.map(Selectable.targetStatus);

  unselectedLevels |> Array.append(unselectedStatus);
};

let selected = state => {
  let selectedLevel =
    state.selectedLevel
    |> OptionUtils.mapWithDefault(
         selectedLevel => [|Selectable.level(selectedLevel)|],
         [||],
       );

  let selectedStatus =
    state.selectedStatus
    |> OptionUtils.mapWithDefault(
         selectedStatus => {[|Selectable.targetStatus(selectedStatus)|]},
         [||],
       );

  selectedLevel |> Array.append(selectedStatus);
};

let onSelectFilter = (send, selectable) =>
  switch (selectable) {
  | Selectable.TargetStatus(status) => send(SelectStatus(status))
  | Level(level) => send(SelectLevel(level))
  };

let onDeselectFilter = (send, selectable) =>
  switch (selectable) {
  | Selectable.TargetStatus(_status) => send(DeselectStatus)
  | Level(_level) => send(DeselectLevel)
  };

module Sortable = {
  type t = sortBy;

  let criterion = t => t.criterion;
  let criterionType = t => t.criterionType;
};

module SubmissionsSorter = Sorter.Make(Sortable);

let submissionsSorter = (state, send) => {
  let criteria = [|{criterion: "Submitted At", criterionType: `Number}|];
  <div
    ariaLabel="Change submissions sorting"
    className="flex-shrink-0 mt-3 md:mt-0 md:ml-2">
    <label className="block text-tiny font-semibold uppercase">
      {"Sort by:" |> str}
    </label>
    <SubmissionsSorter
      criteria
      selectedCriterion={state.sortBy}
      direction={state.sortDirection}
      onDirectionChange={sortDirection => {
        send(UpdateSortDirection(sortDirection))
      }}
      onCriterionChange={_ => ()}
    />
  </div>;
};

let filterPlaceholder = filter => {
  switch (filter.selectedLevel, filter.selectedStatus) {
  | (None, Some(_)) => "Filter by level"
  | (None, None) => "Filter by level, or by review status"
  | (Some(_), Some(_)) => "Filter by another level"
  | (Some(_), None) => "Filter by another level, or by review status"
  };
};

let reducer = (state, action) => {
  switch (action) {
  | SelectLevel(level) => {
      ...state,
      filter: {
        ...state.filter,
        selectedLevel: Some(level),
      },
      filterString: "",
    }
  | DeselectLevel => {
      ...state,
      filter: {
        ...state.filter,
        selectedLevel: None,
      },
    }
  | SelectStatus(targetStatus) => {
      ...state,
      filter: {
        ...state.filter,
        selectedStatus: Some(targetStatus),
      },
      filterString: "",
    }
  | DeselectStatus => {
      ...state,
      filter: {
        ...state.filter,
        selectedStatus: None,
      },
    }
  | UpdateSortDirection(sortDirection) => {...state, sortDirection}
  | UpdateFilterString(filterString) => {...state, filterString}
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | BeginReloading => {...state, loading: Reloading}
  | CompletedLoading => {...state, loading: Loaded}
  };
};

let updateStudentSubmissions =
    (send, updateSubmissionsCB, endCursor, hasNextPage, submissions, nodes) => {
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

  let submissionsData: Submissions.t =
    switch (hasNextPage, endCursor) {
    | (true, None)
    | (false, _) => FullyLoaded(updatedSubmissions)
    | (true, Some(cursor)) => PartiallyLoaded(updatedSubmissions, cursor)
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

  | `Pending =>
    <div
      className="bg-green-100 border border-green-500 flex-shrink-0 leading-normal text-green-800 font-semibold px-3 py-px rounded">
      {"Submitted" |> str}
    </div>
  };

let submissionCardClasses = submission =>
  "flex flex-col md:flex-row items-start md:items-center justify-between bg-white border-l-3 p-3 md:py-6 md:px-5 mt-4 cursor-pointer rounded-r-lg shadow hover:border-primary-500 hover:text-primary-500 hover:shadow-md "
  ++ (
    switch (submission |> Submission.status) {
    | `Failed => "border-red-500"
    | `Passed => "border-green-500"
    | `Pending => "border-orange-400"
    }
  );

let showSubmission = (submissions, levels) =>
  <div>
    {submissions
     |> Array.map(submission =>
          <a
            key={submission |> Submission.id}
            href={"/submissions/" ++ (submission |> Submission.id)}
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
        )
     |> React.array}
  </div>;

let showSubmissions = (submissions, levels) =>
  submissions |> ArrayUtils.isEmpty
    ? <div
        className="course-review__reviewed-empty text-lg font-semibold text-center py-4">
        <h5 className="py-4 mt-4 bg-gray-200 text-gray-800 font-semibold">
          {"No submissions to show " |> str}
        </h5>
      </div>
    : showSubmission(submissions, levels);

[@react.component]
let make = (~studentId, ~levels, ~submissions, ~updateSubmissionsCB) => {
  let (state, send) =
    React.useReducer(
      reducer,
      {
        filter: {
          selectedLevel: None,
          selectedStatus: None,
        },
        sortDirection: `Ascending,
        filterString: "",
        loading: Reloading,
        sortBy: {
          criterion: "Submitted At",
          criterionType: `Number,
        },
      },
    );

  React.useEffect2(
    () => {
      send(BeginReloading);
      getStudentSubmissions(
        studentId,
        None,
        send,
        state.filter.selectedLevel,
        state.filter.selectedStatus,
        state.sortDirection,
        [||],
        updateSubmissionsCB,
      );

      None;
    },
    (state.filter, state.sortDirection),
  );
  <div className="max-w-3xl mx-auto">
    {<div className="md:flex w-full items-start pb-4">
       <div className="flex-1">
         <label className="block text-tiny font-semibold uppercase">
           {"Filter by:" |> str}
         </label>
         <Multiselect
           id="filter"
           unselected={unselected(levels, state.filter)}
           selected={selected(state.filter)}
           onSelect={onSelectFilter(send)}
           onDeselect={onDeselectFilter(send)}
           value={state.filterString}
           onChange={filterString => send(UpdateFilterString(filterString))}
           placeholder={filterPlaceholder(state.filter)}
         />
       </div>
       {submissionsSorter(state, send)}
     </div>}
    <div ariaLabel="student-submissions">
      {switch ((submissions: Submissions.t)) {
       | Unloaded =>
         SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.card())
       | PartiallyLoaded(submissions, cursor) =>
         <div>
           {showSubmissions(submissions, levels)}
           {switch (state.loading) {
            | Loaded =>
              <button
                className="btn btn-primary-ghost cursor-pointer w-full mt-4"
                onClick={_ =>
                  getStudentSubmissions(
                    studentId,
                    Some(cursor),
                    send,
                    state.filter.selectedLevel,
                    state.filter.selectedStatus,
                    state.sortDirection,
                    submissions,
                    updateSubmissionsCB,
                  )
                }>
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
       | FullyLoaded(submissions) => showSubmissions(submissions, levels)
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

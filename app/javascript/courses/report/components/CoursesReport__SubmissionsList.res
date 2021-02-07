open CoursesReport__Types
let str = React.string
let tc = I18n.t(~scope="components.CoursesReport__SubmissionsList")
let ts = I18n.t(~scope="shared")

type targetStatus = [#PendingReview | #Rejected | #Completed]

type sortDirection = [#Ascending | #Descending]

type sortBy = {
  criterion: string,
  criterionType: [#String | #Number],
}

let sortBy = {criterion: tc("submitted_at"), criterionType: #Number}

type loading =
  | Loaded
  | Reloading
  | LoadingMore

type filter = {
  selectedLevel: option<Level.t>,
  selectedStatus: option<targetStatus>,
}

type state = {
  loading: loading,
  filterString: string,
}

type action =
  | UpdateFilterString(string)
  | BeginLoadingMore
  | BeginReloading
  | CompletedLoading

let statusString = targetStatus =>
  switch targetStatus {
  | #PendingReview => tc("pending_review")
  | #Rejected => tc("rejected")
  | #Completed => tc("completed")
  }

module StudentSubmissionsQuery = %graphql(
  `
   query StudentsReportSubmissionsQuery($studentId: ID!, $after: String, $status: SubmissionReviewStatus, $levelId: ID, $sortDirection: SortDirection!) {
    studentSubmissions(studentId: $studentId, after: $after, first: 20 , status: $status, levelId: $levelId, sortDirection: $sortDirection) {
       nodes {
        id
        createdAt
        levelId
        targetId
        passedAt
        title
        evaluatedAt
        studentIds
        teamTarget
       }
       pageInfo {
         hasNextPage
         endCursor
       }
      }
    }
   `
)

module Selectable = {
  type t =
    | Level(Level.t)
    | TargetStatus(targetStatus)

  let label = t =>
    switch t {
    | Level(level) => Some(LevelLabel.format(level |> Level.number |> string_of_int))
    | TargetStatus(_targetStatus) => Some(tc("status"))
    }

  let value = t =>
    switch t {
    | Level(level) => level |> Level.name
    | TargetStatus(targetStatus) => statusString(targetStatus)
    }

  let searchString = t =>
    switch t {
    | Level(level) =>
      LevelLabel.searchString(level |> Level.number |> string_of_int, level |> Level.name)
    | TargetStatus(targetStatus) => "status " ++ statusString(targetStatus)
    }

  let color = t =>
    switch t {
    | Level(_level) => "gray"
    | TargetStatus(status) =>
      switch status {
      | #PendingReview => "blue"
      | #Completed => "green"
      | #Rejected => "red"
      }
    }
  let level = level => Level(level)
  let targetStatus = targetStatus => TargetStatus(targetStatus)
}

module Multiselect = MultiselectDropdown.Make(Selectable)

let unselected = (levels, selectedLevel, selectedStatus) => {
  let unselectedLevels =
    levels
    |> Js.Array.filter(level => Level.number(level) != 0)
    |> Js.Array.filter(level =>
      selectedLevel |> OptionUtils.mapWithDefault(
        selectedLevel => level |> Level.id != (selectedLevel |> Level.id),
        true,
      )
    )
    |> Array.map(Selectable.level)

  let unselectedStatus =
    [#PendingReview, #Rejected, #Completed]
    |> Js.Array.filter(status =>
      selectedStatus |> OptionUtils.mapWithDefault(selectedStatus => status != selectedStatus, true)
    )
    |> Array.map(Selectable.targetStatus)

  unselectedLevels |> Array.append(unselectedStatus)
}

let selected = (selectedLevel, selectedStatus) => {
  let selectedLevel =
    selectedLevel |> OptionUtils.mapWithDefault(
      selectedLevel => [Selectable.level(selectedLevel)],
      [],
    )

  let selectedStatus =
    selectedStatus |> OptionUtils.mapWithDefault(
      selectedStatus => [Selectable.targetStatus(selectedStatus)],
      [],
    )

  selectedLevel |> Array.append(selectedStatus)
}

let onSelectFilter = (send, updateSelectedLevelCB, updateSelectedStatusCB, selectable) => {
  send(UpdateFilterString(""))
  switch selectable {
  | Selectable.TargetStatus(status) => updateSelectedStatusCB(Some(status))
  | Level(level) => updateSelectedLevelCB(Some(level))
  }
}

let onDeselectFilter = (updateSelectedLevelCB, updateSelectedStatusCB, selectable) =>
  switch selectable {
  | Selectable.TargetStatus(_status) => updateSelectedStatusCB(None)
  | Level(_level) => updateSelectedLevelCB(None)
  }

module Sortable = {
  type t = sortBy

  let criterion = t => t.criterion
  let criterionType = t => t.criterionType
}

module SubmissionsSorter = Sorter.Make(Sortable)

let submissionsSorter = (sortDirection, updateSortDirectionCB) => {
  let criteria = [sortBy]
  <div ariaLabel="Change submissions sorting" className="flex-shrink-0 mt-3 md:mt-0 md:ml-2">
    <label className="block text-tiny font-semibold uppercase"> {tc("sort_by") |> str} </label>
    <SubmissionsSorter
      criteria
      selectedCriterion=sortBy
      direction=sortDirection
      onDirectionChange={sortDirection => updateSortDirectionCB(sortDirection)}
      onCriterionChange={_ => ()}
    />
  </div>
}

let filterPlaceholder = (selectedLevel, selectedStatus) =>
  switch (selectedLevel, selectedStatus) {
  | (None, Some(_)) => tc("filter_by_level")
  | (None, None) => tc("filter_by_level_or_status")
  | (Some(_), Some(_)) => tc("filter_by_another_level")
  | (Some(_), None) => tc("filter_by_another_level_or_status")
  }

let reducer = (state, action) =>
  switch action {
  | UpdateFilterString(filterString) => {...state, filterString: filterString}
  | BeginLoadingMore => {...state, loading: LoadingMore}
  | BeginReloading => {...state, loading: Reloading}
  | CompletedLoading => {...state, loading: Loaded}
  }

let updateStudentSubmissions = (
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
  let updatedSubmissions = Array.append(
    switch nodes {
    | None => []
    | Some(submissionsArray) => submissionsArray |> Submission.makeFromJs
    } |> ArrayUtils.flatten,
    submissions,
  )

  let filter = Submissions.makeFilter(selectedLevel, selectedStatus)

  let submissionsData = Submissions.make(~submissions=updatedSubmissions, ~filter, ~sortDirection)

  let submissionsData: Submissions.t = switch (hasNextPage, endCursor) {
  | (true, None)
  | (false, _) =>
    FullyLoaded(submissionsData)
  | (true, Some(cursor)) => PartiallyLoaded(submissionsData, cursor)
  }

  updateSubmissionsCB(submissionsData)
  send(CompletedLoading)
}

let getStudentSubmissions = (
  studentId,
  cursor,
  send,
  level,
  status,
  sortDirection,
  submissions,
  updateSubmissionsCB,
) => {
  let levelId = level->Belt.Option.flatMap(level => Some(Level.id(level)))
  let status = status->Belt.Option.flatMap(status => Some(status))
  switch cursor {
  | Some(cursor) =>
    StudentSubmissionsQuery.make(~studentId, ~after=cursor, ~sortDirection, ~levelId?, ~status?, ())
  | None => StudentSubmissionsQuery.make(~studentId, ~sortDirection, ~levelId?, ~status?, ())
  }
  |> GraphqlQuery.sendQuery
  |> Js.Promise.then_(response => {
    response["studentSubmissions"]["nodes"] |> updateStudentSubmissions(
      send,
      updateSubmissionsCB,
      response["studentSubmissions"]["pageInfo"]["endCursor"],
      response["studentSubmissions"]["pageInfo"]["hasNextPage"],
      submissions,
      level,
      status,
      sortDirection,
    )
    Js.Promise.resolve()
  })
  |> ignore
}

let showSubmissionStatus = submission =>
  switch submission |> Submission.status {
  | #Rejected =>
    <div
      className="bg-red-100 border border-red-500 flex-shrink-0 leading-normal text-red-800 font-semibold px-3 py-px rounded">
      {tc("rejected") |> str}
    </div>

  | #Completed =>
    <div
      className="bg-green-100 border border-green-500 flex-shrink-0 leading-normal text-green-800 font-semibold px-3 py-px rounded">
      {tc("completed") |> str}
    </div>

  | #PendingReview =>
    <div
      className="bg-blue-100 border border-blue-500 flex-shrink-0 leading-normal text-blue-800 font-semibold px-3 py-px rounded">
      {tc("pending_review") |> str}
    </div>
  }

let submissionCardClasses = submission =>
  "flex flex-col md:flex-row items-start md:items-center justify-between bg-white border-l-3 p-3 md:py-6 md:px-5 mt-4 cursor-pointer rounded-r-lg shadow hover:border-primary-500 hover:text-primary-500 hover:shadow-md " ++
  switch submission |> Submission.status {
  | #Rejected => "border-red-500"
  | #Completed => "border-green-500"
  | #PendingReview => "border-blue-500"
  }

let showSubmission = (submissions, levels, teamStudentIds) =>
  <div> {submissions |> Array.map(submission => {
      let teamMismatch = switch submission |> Submission.targetRole {
      | Student => false
      | Team(studentIds) => teamStudentIds != studentIds
      }

      let submissionHref = teamMismatch
        ? "/submissions/" ++ Submission.id(submission)
        : "/targets/" ++ Submission.targetId(submission)

      <div
        key={submission |> Submission.id}
        ariaLabel={"student-submission-" ++ (submission |> Submission.id)}>
        <a className="block relative z-10" href=submissionHref>
          <div
            key={submission |> Submission.id}
            ariaLabel={"student-submission-card-" ++ (submission |> Submission.id)}
            className={submissionCardClasses(submission)}>
            <div className="w-full md:w-3/4">
              <div className="block text-sm md:pr-2">
                <span className="bg-gray-300 text-xs font-semibold px-2 py-px rounded">
                  {submission |> Submission.levelId |> Level.levelLabel(levels) |> str}
                </span>
                <span className="ml-2 font-semibold text-base">
                  {submission |> Submission.title |> str}
                </span>
              </div>
              <div className="mt-1 ml-px text-xs text-gray-900">
                <span className="ml-1">
                  {tc(
                    ~variables=[("date", submission |> Submission.createdAtPretty)],
                    "submitted_on",
                  ) |> str}
                </span>
              </div>
            </div>
            <div className="w-auto md:w-1/4 text-xs flex justify-end mt-2 md:mt-0">
              {showSubmissionStatus(submission)}
            </div>
          </div>
        </a>
        {teamMismatch
          ? <div
              ariaLabel={"Team change notice for submission " ++ Submission.id(submission)}
              className="w-full text-xs rounded-b bg-indigo-100 text-indigo-700 px-4 pt-3 pb-2 -mt-1 flex flex-1 justify-between items-center">
              <div className="flex flex-1 justify-start items-center pr-8">
                <FaIcon classes="fas fa-exclamation-triangle text-sm md:text-base mt-1" />
                <div className="inline-block pl-3">
                  {tc("submission_not_considered") |> str}
                  <HelpIcon className="ml-1">
                    <span
                      dangerouslySetInnerHTML={"__html": tc("submission_not_considered_help")}
                    />
                  </HelpIcon>
                </div>
              </div>
              <a
                href={"/targets/" ++ Submission.targetId(submission)}
                className="flex-shrink-0 px-2 py-1 text-xs font-semibold text-indigo-700 hover:bg-indigo-200 hover:text-indigo-800 rounded">
                <span className="hidden md:inline"> {tc("view") |> str} </span>
                {ts("target") |> str}
                <FaIcon classes="fas fa-arrow-right ml-2" />
              </a>
            </div>
          : React.null}
      </div>
    }) |> React.array} </div>

let showSubmissions = (submissions, levels, teamStudentIds) =>
  submissions |> ArrayUtils.isEmpty
    ? <div className="course-review__reviewed-empty text-lg font-semibold text-center py-4">
        <h5 className="py-4 mt-4 bg-gray-200 text-gray-800 font-semibold">
          {tc("no_submissions_to_show") |> str}
        </h5>
      </div>
    : showSubmission(submissions, levels, teamStudentIds)

@react.component
let make = (
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
  let (state, send) = React.useReducer(reducer, {filterString: "", loading: Loaded})

  React.useEffect3(() => {
    if submissions |> Submissions.needsReloading(selectedLevel, selectedStatus, sortDirection) {
      send(BeginReloading)
      getStudentSubmissions(
        studentId,
        None,
        send,
        selectedLevel,
        selectedStatus,
        sortDirection,
        [],
        updateSubmissionsCB,
      )
    }

    None
  }, (selectedLevel, selectedStatus, sortDirection))
  <div className="max-w-3xl mx-auto">
    <div className="md:flex w-full items-start pb-4">
      <div className="flex-1">
        <label className="block text-tiny font-semibold uppercase"> {"Filter by:" |> str} </label>
        <Multiselect
          id="filter"
          unselected={unselected(levels, selectedLevel, selectedStatus)}
          selected={selected(selectedLevel, selectedStatus)}
          onSelect={onSelectFilter(send, updateSelectedLevelCB, updateSelectedStatusCB)}
          onDeselect={onDeselectFilter(updateSelectedLevelCB, updateSelectedStatusCB)}
          value=state.filterString
          onChange={filterString => send(UpdateFilterString(filterString))}
          placeholder={filterPlaceholder(selectedLevel, selectedStatus)}
        />
      </div>
      {submissionsSorter(sortDirection, updateSortDirectionCB)}
    </div>
    <div ariaLabel="student-submissions">
      {switch (submissions: Submissions.t) {
      | Unloaded => SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.card())
      | PartiallyLoaded({submissions}, cursor) =>
        <div>
          {showSubmissions(submissions, levels, teamStudentIds)}
          {switch state.loading {
          | Loaded =>
            <button
              className="btn btn-primary-ghost cursor-pointer w-full mt-4"
              onClick={_ => {
                send(BeginLoadingMore)
                getStudentSubmissions(
                  studentId,
                  Some(cursor),
                  send,
                  selectedLevel,
                  selectedStatus,
                  sortDirection,
                  submissions,
                  updateSubmissionsCB,
                )
              }}>
              {tc("load_more") |> str}
            </button>
          | LoadingMore => SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.card())
          | Reloading => React.null
          }}
        </div>
      | FullyLoaded({submissions}) => showSubmissions(submissions, levels, teamStudentIds)
      }}
    </div>
    {switch submissions {
    | Unloaded => React.null

    | _ =>
      let loading = switch state.loading {
      | Loaded => false
      | Reloading => true
      | LoadingMore => false
      }
      <LoadingSpinner loading />
    }}
  </div>
}

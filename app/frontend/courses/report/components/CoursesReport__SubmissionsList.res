open CoursesReport__Types
let str = React.string
let tr = I18n.t(~scope="components.CoursesReport__SubmissionsList")
let ts = I18n.t(~scope="shared")

type targetStatus = [#PendingReview | #Rejected | #Completed]

type sortDirection = [#Ascending | #Descending]

type sortBy = {
  criterion: string,
  criterionType: [#String | #Number],
}

let sortBy = {criterion: tr("submitted_at"), criterionType: #Number}

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
  | #PendingReview => tr("pending_review")
  | #Rejected => tr("rejected")
  | #Completed => tr("completed")
  }

module StudentSubmissionsQuery = %graphql(`
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
        milestoneNumber
       }
       pageInfo {
         hasNextPage
         endCursor
       }
      }
    }
   `)

module Selectable = {
  type t =
    | Level(Level.t)
    | TargetStatus(targetStatus)

  let label = t =>
    switch t {
    | Level(level) => Some(LevelLabel.format(level |> Level.number |> string_of_int))
    | TargetStatus(_targetStatus) => Some(tr("status"))
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
  <div ariaLabel="Change submissions sorting" className="shrink-0 mt-3 md:mt-0 md:ms-2">
    <label className="block text-tiny font-semibold uppercase"> {tr("sort_by") |> str} </label>
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
  | (None, Some(_)) => tr("filter_by_level")
  | (None, None) => tr("filter_by_level_or_status")
  | (Some(_), Some(_)) => tr("filter_by_another_level")
  | (Some(_), None) => tr("filter_by_another_level_or_status")
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
  let updatedSubmissions = Js.Array.concat(Submission.makeFromJs(nodes), submissions)

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

  StudentSubmissionsQuery.make({
    studentId: studentId,
    after: cursor,
    sortDirection: sortDirection,
    levelId: levelId,
    status: status,
  })
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
      className="bg-red-100 border border-red-500 shrink-0 leading-normal text-red-800 font-semibold px-3 py-px rounded">
      {tr("rejected") |> str}
    </div>

  | #Completed =>
    <div
      className="bg-green-100 border border-green-500 shrink-0 leading-normal text-green-800 font-semibold px-3 py-px rounded">
      {tr("completed") |> str}
    </div>

  | #PendingReview =>
    <div
      className="bg-blue-100 border border-blue-500 shrink-0 leading-normal text-blue-800 font-semibold px-3 py-px rounded">
      {tr("pending_review") |> str}
    </div>
  }

let submissionCardClasses = submission =>
  "flex flex-col md:flex-row items-start md:items-center justify-between rounded-lg bg-white border-s-3 p-3 md:py-6 md:px-5 mt-4 cursor-pointer shadow hover:border-primary-500 hover:text-primary-500 hover:shadow-md focus:outline-none focus:border-2 focus:border-focusColor-500 " ++
  switch submission |> Submission.status {
  | #Rejected => "border-red-500"
  | #Completed => "border-green-500"
  | #PendingReview => "border-blue-500"
  }

let showSubmission = (submissions, teamStudentIds) =>
  <div>
    {submissions
    |> Array.map(submission => {
      let teamMismatch = switch submission |> Submission.targetRole {
      | Student => false
      | Team(studentIds) => teamStudentIds != studentIds
      }

      let submissionHref = teamMismatch
        ? "/submissions/" ++ Submission.id(submission)
        : "/targets/" ++ Submission.targetId(submission)

      <div className="" key={submission |> Submission.id}>
        <a
          className="block relative z-10 rounded-lg focus:outline-none focus:ring focus-ring-inset focus:ring-focusColor-500"
          ariaLabel={"Student submission " ++ (submission |> Submission.id)}
          href=submissionHref>
          <div key={submission |> Submission.id} className={submissionCardClasses(submission)}>
            <div className="w-full md:w-3/4">
              <div className="block text-sm md:pe-2">
                <span className="ms-1 font-semibold text-base">
                  {(Belt.Option.mapWithDefault(Submission.milestoneNumber(submission), "", number =>
                    "M" ++ string_of_int(number) ++ " - "
                  ) ++
                  submission->Submission.title)->str}
                </span>
              </div>
              <div className="mt-1 ms-px text-xs text-gray-900">
                <span className="ms-1">
                  {tr(
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
              className="w-full text-xs rounded-b bg-blue-100 text-blue-700 px-4 pt-3 pb-2 -mt-1 flex flex-1 justify-between items-center">
              <div className="flex flex-1 justify-start items-center pe-8">
                <FaIcon classes="fas fa-exclamation-triangle text-sm md:text-base mt-1" />
                <div className="inline-block ps-3 ">
                  {tr("submission_not_considered") |> str}
                  <HelpIcon className="ms-1">
                    <span
                      dangerouslySetInnerHTML={"__html": tr("submission_not_considered_help")}
                    />
                  </HelpIcon>
                </div>
              </div>
              <a
                href={"/targets/" ++ Submission.targetId(submission)}
                className="shrink-0 px-2 py-1 text-xs font-semibold text-blue-700 hover:bg-blue-200 hover:text-blue-800 rounded focus:outline-none focus:ring-2 focus:ring-inset focus:ring-focusColor-500">
                <span className="hidden md:inline"> {tr("view") |> str} </span>
                {ts("target") |> str}
                <FaIcon classes="fas fa-arrow-right ms-2 rtl:rotate-180" />
              </a>
            </div>
          : React.null}
      </div>
    })
    |> React.array}
  </div>

let showSubmissions = (submissions, teamStudentIds) =>
  submissions |> ArrayUtils.isEmpty
    ? <div className="course-review__reviewed-empty text-lg font-semibold text-center py-4">
        <h5 className="py-4 mt-4 bg-gray-50 text-gray-800 font-semibold">
          {tr("no_submissions_to_show") |> str}
        </h5>
      </div>
    : showSubmission(submissions, teamStudentIds)

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
    <div role="form" className="md:flex items-end w-full pb-4 mt-4">
      <div className="flex-1">
        <label htmlFor="filter" className="block text-tiny font-semibold uppercase pb-1">
          {"Filter by:" |> str}
        </label>
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
    <div ariaLabel="Student submissions">
      {switch (submissions: Submissions.t) {
      | Unloaded => SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.card())
      | PartiallyLoaded({submissions}, cursor) =>
        <div>
          {showSubmissions(submissions, teamStudentIds)}
          {switch state.loading {
          | Loaded =>
            <button
              className="btn btn-primary-ghost cursor-pointer w-full mt-4 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-focusColor-500"
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
              {ts("load_more") |> str}
            </button>
          | LoadingMore => SkeletonLoading.multiple(~count=3, ~element=SkeletonLoading.card())
          | Reloading => React.null
          }}
        </div>
      | FullyLoaded({submissions}) => showSubmissions(submissions, teamStudentIds)
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

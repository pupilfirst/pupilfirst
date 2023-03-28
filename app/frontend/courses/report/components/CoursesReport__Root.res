%%raw(`import "./CoursesReport.css"`)
open CoursesReport__Types

let str = React.string

let tr = I18n.t(~scope="components.CoursesReport")

type selectedTab = [#Overview | #Submissions]

type targetStatus = [#PendingReview | #Rejected | #Completed]

type sortDirection = [#Ascending | #Descending]

type submissionsFilter = {
  selectedLevel: option<Level.t>,
  selectedStatus: option<targetStatus>,
}

type state = {
  selectedTab: selectedTab,
  overviewData: OverviewData.t,
  submissionsData: Submissions.t,
  submissionsFilter: submissionsFilter,
  sortDirection: sortDirection,
}

type action =
  | SelectOverviewTab
  | SelectSubmissionsTab
  | SaveOverviewData(OverviewData.t)
  | SaveSubmissions(Submissions.t)
  | UpdateLevelFilter(option<Level.t>)
  | UpdateStatusFilter(option<targetStatus>)
  | UpdateSortDirection(sortDirection)

let buttonClasses = selected =>
  "cursor-pointer flex flex-1 justify-center md:flex-auto rounded-md p-1.5 md:border-b-3 md:rounded-b-none md:border-transparent md:px-4 md:hover:bg-gray-50 md:py-2 text-sm font-semibold text-gray-800 hover:text-primary-600 hover:bg-gray-50 focus:outline-none focus:ring-inset focus:ring-2 focus:bg-gray-50 focus:ring-focusColor-500 md:focus:border-b-none md:focus:rounded-t-md " ++ (
    selected
      ? "bg-white shadow md:shadow-none rounded-md md:rounded-none md:bg-transparent md:border-b-3 hover:bg-white md:hover:bg-transparent text-primary-500 md:border-primary-500"
      : ""
  )

let reducer = (state, action) =>
  switch action {
  | SelectOverviewTab => {...state, selectedTab: #Overview}
  | SelectSubmissionsTab => {...state, selectedTab: #Submissions}
  | SaveOverviewData(overviewData) => {...state, overviewData: overviewData}
  | SaveSubmissions(submissionsData) => {...state, submissionsData: submissionsData}
  | UpdateLevelFilter(level) => {
      ...state,
      submissionsFilter: {
        ...state.submissionsFilter,
        selectedLevel: level,
      },
    }
  | UpdateStatusFilter(status) => {
      ...state,
      submissionsFilter: {
        ...state.submissionsFilter,
        selectedStatus: status,
      },
    }
  | UpdateSortDirection(sortDirection) => {...state, sortDirection: sortDirection}
  }

module StudentReportOverviewQuery = %graphql(`
    query StudentReportOverviewQuery($studentId: ID!) {
      studentDetails(studentId: $studentId) {
        evaluationCriteria {
          id, name, maxGrade, passGrade
        },
        student {
          level {
            id
          }
        }
        totalTargets
        targetsCompleted
        targetsPendingReview
        completedLevelIds
        quizScores
        averageGrades {
          evaluationCriterionId
          averageGrade
        }
      }
    }
  `)

let saveOverviewData = (studentId, send, data) =>
  send(SaveOverviewData(Loaded(data |> StudentOverview.makeFromJs(studentId))))

let getOverviewData = (studentId, send, ()) => {
  StudentReportOverviewQuery.make({studentId: studentId})
  |> Js.Promise.then_(response => {
    response["studentDetails"] |> saveOverviewData(studentId, send)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_ => Js.Promise.resolve())
  |> ignore

  None
}

let updateSubmissions = (send, submissions) => send(SaveSubmissions(submissions))

@react.component
let make = (~studentId, ~levels, ~coaches, ~teamStudentIds) => {
  let (state, send) = React.useReducer(
    reducer,
    {
      selectedTab: #Overview,
      overviewData: Unloaded,
      submissionsData: Unloaded,
      submissionsFilter: {
        selectedLevel: None,
        selectedStatus: None,
      },
      sortDirection: #Descending,
    },
  )

  React.useEffect1(getOverviewData(studentId, send), [studentId])

  <div
    role="main"
    ariaLabel="Report"
    className="bg-gray-50 pt-9 pb-8 px-3 -mt-7 border border-transparent shadow rounded-lg">
    <div className="bg-gray-50 static">
      <div className="max-w-3xl mx-auto">
        <div className="flex pt-3 mb-4 md:border-b border-gray-300">
          <div
            role="tablist"
            ariaLabel="Status tabs"
            className="flex flex-1 md:flex-none p-1 md:p-0 space-x-1 md:space-x-0 text-center rounded-lg justify-between md:justify-start bg-gray-300 md:bg-transparent">
            <button
              role="tab"
              ariaSelected={state.selectedTab == #Overview}
              className={buttonClasses(state.selectedTab == #Overview)}
              onClick={_ => send(SelectOverviewTab)}>
              {tr("button_overview_text") |> str}
            </button>
            <button
              role="tab"
              ariaSelected={state.selectedTab == #Submissions}
              className={buttonClasses(state.selectedTab == #Submissions)}
              onClick={_ => send(SelectSubmissionsTab)}>
              {tr("button_submissions_text") |> str}
            </button>
          </div>
        </div>
      </div>
    </div>
    <div className="">
      {switch state.selectedTab {
      | #Overview => <CoursesReport__Overview overviewData=state.overviewData levels coaches />
      | #Submissions =>
        <CoursesReport__SubmissionsList
          studentId
          teamStudentIds
          levels
          submissions=state.submissionsData
          updateSubmissionsCB={updateSubmissions(send)}
          selectedLevel=state.submissionsFilter.selectedLevel
          selectedStatus=state.submissionsFilter.selectedStatus
          sortDirection=state.sortDirection
          updateSelectedLevelCB={level => send(UpdateLevelFilter(level))}
          updateSelectedStatusCB={status => send(UpdateStatusFilter(status))}
          updateSortDirectionCB={direction => send(UpdateSortDirection(direction))}
        />
      }}
    </div>
  </div>
}

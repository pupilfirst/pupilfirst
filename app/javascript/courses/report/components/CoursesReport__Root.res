%bs.raw(`require("./CoursesReport.css")`)
open CoursesReport__Types

let str = React.string

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
  "w-1/2 md:w-auto py-2 px-3 md:px-6 font-semibold text-sm focus:outline-none " ++ (
    selected
      ? "bg-primary-100 shadow-inner text-primary-500"
      : "bg-white shadow-md hover:shadow hover:text-primary-500 hover:bg-gray-100"
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

module StudentReportOverviewQuery = %graphql(
  `
    query StudentReportOverviewQuery($studentId: ID!) {
      studentDetails(studentId: $studentId) {
        evaluationCriteria {
          id, name, maxGrade, passGrade
        },
        team {
          id
          name
          levelId
          droppedOutAt
          accessEndsAt
          students {
            id
            name
            title
            avatarUrl
          }
          coachUserIds
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
  `
)

let saveOverviewData = (studentId, send, data) =>
  send(SaveOverviewData(Loaded(data |> StudentOverview.makeFromJs(studentId))))

let getOverviewData = (studentId, send, ()) => {
  StudentReportOverviewQuery.make(~studentId, ())
  |> GraphqlQuery.sendQuery
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

  <div className="bg-gray-100 pt-9 pb-8 px-3 -mt-7 border border-transparent shadow rounded-lg">
    <div className="bg-gray-100 static">
      <div className="max-w-3xl mx-auto">
        <div className="flex flex-col md:flex-row items-end lg:items-center py-4">
          <div
            ariaLabel="status-tab"
            className="course-report__category-tab w-full md:w-auto flex rounded-lg border border-gray-400">
            <button
              className={buttonClasses(state.selectedTab == #Overview)}
              onClick={_ => send(SelectOverviewTab)}>
              {"Overview" |> str}
            </button>
            <button
              className={buttonClasses(state.selectedTab == #Submissions)}
              onClick={_ => send(SelectSubmissionsTab)}>
              {"Submissions" |> str}
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

%%raw(`import "./CoursesReport.css"`)
open CoursesReport__Types

let str = React.string

let tr = I18n.t(~scope="components.CoursesReport")

type selectedTab = [#Overview | #Submissions]

type targetStatus = [#PendingReview | #Rejected | #Completed]

type sortDirection = [#Ascending | #Descending]

type submissionsFilter = {selectedStatus: option<targetStatus>}

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
  | UpdateStatusFilter(option<targetStatus>)
  | UpdateSortDirection(sortDirection)

let buttonClasses = selected =>
  "cursor-pointer flex flex-1 justify-center md:flex-auto rounded-md p-1.5 md:border-b-3 md:rounded-b-none  md:px-4 md:hover:bg-gray-50 md:py-2 text-sm font-semibold text-gray-800 hover:text-primary-600 hover:bg-gray-50 focus:outline-none focus:ring-inset focus:ring-2 focus:bg-gray-50 focus:ring-focusColor-500 md:focus:border-b-none md:focus:rounded-t-md " ++ (
    selected
      ? "bg-white shadow md:shadow-none rounded-md md:rounded-none md:bg-transparent md:border-b-3 hover:bg-white md:hover:bg-transparent text-primary-500 md:border-primary-500"
      : "md:border-transparent"
  )

let reducer = (state, action) =>
  switch action {
  | SelectOverviewTab => {...state, selectedTab: #Overview}
  | SelectSubmissionsTab => {...state, selectedTab: #Submissions}
  | SaveOverviewData(overviewData) => {...state, overviewData: overviewData}
  | SaveSubmissions(submissionsData) => {...state, submissionsData: submissionsData}
  | UpdateStatusFilter(status) => {
      ...state,
      submissionsFilter: {
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
        }
        student {
          cohort {
            name
          }
        }
        totalTargets
        targetsCompleted
        targetsPendingReview
        quizScores
        averageGrades {
          evaluationCriterionId
          averageGrade
        }
        milestoneTargetsCompletionStatus {
          id
          title
          completed
          milestoneNumber
        }
      }
    }
  `)

let getOverviewData = (studentId, send, ()) => {
  StudentReportOverviewQuery.fetch({studentId: studentId})
  |> Js.Promise.then_((response: StudentReportOverviewQuery.t) => {
    let evaluationCriteria =
      response.studentDetails.evaluationCriteria->Js.Array2.map(evaluationCriterion =>
        CoursesReport__EvaluationCriterion.make(
          ~id=evaluationCriterion.id,
          ~name=evaluationCriterion.name,
          ~maxGrade=evaluationCriterion.maxGrade,
          ~passGrade=evaluationCriterion.passGrade,
        )
      )

    let averageGrades =
      response.studentDetails.averageGrades->Js.Array2.map(gradeData =>
        StudentOverview.makeAverageGrade(
          ~evaluationCriterionId=gradeData.evaluationCriterionId,
          ~grade=gradeData.averageGrade,
        )
      )

    let milestoneTargetsCompletionStatus =
      response.studentDetails.milestoneTargetsCompletionStatus->Js.Array2.map(milestoneTarget =>
        CoursesReport__MilestoneTargetCompletionStatus.make(
          ~id=milestoneTarget.id,
          ~title=milestoneTarget.title,
          ~milestoneNumber=milestoneTarget.milestoneNumber,
          ~completed=milestoneTarget.completed,
        )
      )

    let overviewData = StudentOverview.make(
      ~id=studentId,
      ~cohortName=response.studentDetails.student.cohort.name,
      ~evaluationCriteria,
      ~totalTargets=response.studentDetails.totalTargets,
      ~targetsCompleted=response.studentDetails.targetsCompleted,
      ~targetsPendingReview=response.studentDetails.targetsPendingReview,
      ~quizScores=response.studentDetails.quizScores,
      ~averageGrades,
      ~milestoneTargetsCompletionStatus,
    )
    send(SaveOverviewData(Loaded(overviewData)))
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_ => Js.Promise.resolve())
  |> ignore

  None
}

let updateSubmissions = (send, submissions) => send(SaveSubmissions(submissions))

@react.component
let make = (~studentId, ~coaches, ~teamStudentIds) => {
  let (state, send) = React.useReducer(
    reducer,
    {
      selectedTab: #Overview,
      overviewData: Unloaded,
      submissionsData: Unloaded,
      submissionsFilter: {
        selectedStatus: None,
      },
      sortDirection: #Descending,
    },
  )

  React.useEffect1(getOverviewData(studentId, send), [studentId])

  <div
    role="main"
    ariaLabel="Report"
    className="md:pt-18 pb-20 md:pb-5 px-4 bg-gray-50 md:h-screen overflow-y-auto">
    <div className="bg-gray-50 sticky top-0 z-10">
      <div className="max-w-3xl mx-auto">
        <div className="flex pt-3 md:border-b border-gray-300">
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
      | #Overview => <CoursesReport__Overview overviewData=state.overviewData coaches />
      | #Submissions =>
        <CoursesReport__SubmissionsList
          studentId
          teamStudentIds
          submissions=state.submissionsData
          updateSubmissionsCB={updateSubmissions(send)}
          selectedStatus=state.submissionsFilter.selectedStatus
          sortDirection=state.sortDirection
          updateSelectedStatusCB={status => send(UpdateStatusFilter(status))}
          updateSortDirectionCB={direction => send(UpdateSortDirection(direction))}
        />
      }}
    </div>
  </div>
}

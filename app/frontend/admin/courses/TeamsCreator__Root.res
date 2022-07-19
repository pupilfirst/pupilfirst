let str = React.string

// MOCK DATA

type cohort = {
  id: string,
  name: string,
}

let cohorts = [
  {id: "1", name: "Cohort 1"},
  {id: "2", name: "Cohort 2"},
  {id: "3", name: "Cohort 3"},
]

// ----------------

let formInvalid = (teamName, selectedCohort) => teamName == "" || selectedCohort == ""

@react.component
let make = (~courseId) => {
  let (teamName, setTeamName) = React.useState(_ => "")
  let (selectedCohort, setSelectedCohort) = React.useState(_ => "")

  <div>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/teams`}
      title="Create new team"
      description={"Course name"}
    />
    <AdminCoursesShared__TeamEditor courseId={courseId} />
  </div>
}

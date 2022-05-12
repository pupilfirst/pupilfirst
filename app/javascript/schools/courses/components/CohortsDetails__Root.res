let str = React.string

@react.component
let make = (~courseId, ~cohortId) => {
  <div>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/cohorts`}
      title="Edit Cohort"
      description={"Update cohort details"}
    />
    <div className="max-w-5xl mx-auto"> {str("Add cohort edit form here!!")} </div>
  </div>
}

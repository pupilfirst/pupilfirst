let str = React.string

@react.component
let make = (~courseId) => {
  <div>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/cohorts`}
      title="Add new cohort"
      description={".........add cohort description here........."}
    />
    <div className="max-w-5xl mx-auto"> {str("Add cohort create form here!!")} </div>
  </div>
}

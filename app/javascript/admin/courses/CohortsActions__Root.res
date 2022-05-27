let str = React.string

let pageLinks = (courseId, cohortId) => [
  School__PageHeader.makeLink(
    ~href={`/school/courses/${courseId}/cohorts/${cohortId}/details`},
    ~title="Details",
    ~icon="fas fa-edit",
    ~selected=false,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/courses/${courseId}/cohorts/${cohortId}/actions`,
    ~title="Actions",
    ~icon="fas fa-cog",
    ~selected=true,
  ),
]

@react.component
let make = (~courseId, ~cohortId) => {
  <div>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/cohorts`}
      title="Edit Cohort"
      description={"{Cohort name}"}
      links={pageLinks(courseId, cohortId)}
    />
    <div className="max-w-5xl mx-auto px-2">
      <h2 className="text-lg font-semibold mt-8"> {"Merge {{Cohort name}} cohort into"->str} </h2>
      <p className="text-sm text-gray-500">
        {"Merge will add students, coaches, and calendars from this cohort to the targeted cohort and delete this cohort."->str}
      </p>
      // <Dropdown
      //       placeholder={}
      //       selectables={}
      //       selected={}
      //       onSelect={}
      //       disabled={}
      //       loading={}
      //     />
      <button
      // onClick={}
        className="btn btn-danger mt-6">
        {"Merge and delete"->str}
      </button>
    </div>
  </div>
}

let str = React.string

let pageLinks = (courseId, studentId) => [
  School__PageHeader.makeLink(
    ~href={`/school/courses/${courseId}/teams/${studentId}/details`},
    ~title="Details",
    ~icon="fas fa-edit",
    ~selected=true,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/courses/${courseId}/teams/${studentId}/actions`,
    ~title="Actions",
    ~icon="fas fa-cog",
    ~selected=false,
  ),
]

@react.component
let make = (~courseId, ~studentId) => {
  <div>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/teams`}
      title="Edit Team"
      description={"Update team details"}
      links={pageLinks(courseId, studentId)}
    />
    <div className="max-w-5xl mx-auto"> {str("Add teams edit form here!!")} </div>
  </div>
}

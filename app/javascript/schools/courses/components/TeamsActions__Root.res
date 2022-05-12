let str = React.string

let pageLinks = (courseId, studentId) => [
  School__PageHeader.makeLink(
    ~href={`/school/courses/${courseId}/teams/${studentId}/details`},
    ~title="Details",
    ~icon="fas fa-edit",
    ~selected=false,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/courses/${courseId}/teams/${studentId}/actions`,
    ~title="Actions",
    ~icon="fas fa-cog",
    ~selected=true,
  ),
]

@react.component
let make = (~courseId, ~studentId) => {
  <div>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/teams`}
      title="Actions"
      description={"Delete team"}
      links={pageLinks(courseId, studentId)}
    />
    <div className="max-w-5xl mx-auto"> {str("Add teams action form here!!")} </div>
  </div>
}

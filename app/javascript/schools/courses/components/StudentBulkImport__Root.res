let str = React.string

let pageLinks = courseId => [
  School__PageHeader.makeLink(
    ~href={`/school/courses/${courseId}/students/new`},
    ~title="Manual",
    ~icon="fas fa-user",
    ~selected=false,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/courses/${courseId}/students/import`,
    ~title="CSV File Import",
    ~icon="fas fa-file",
    ~selected=true,
  ),
]

@react.component
let make = (~courseId, ~search) => {
  <div>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/students`}
      title="Import students"
      description={"Upload the CSV file containing the students you want to add to the course."}
      links={pageLinks(courseId)}
    />
    <div className="max-w-5xl mx-auto"> {str("Add bulk import form here!!")} </div>
  </div>
}

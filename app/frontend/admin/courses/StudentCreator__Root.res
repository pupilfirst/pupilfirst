let str = React.string

let pageLinks = courseId => [
  School__PageHeader.makeLink(
    ~href={`/school/courses/${courseId}/students/new`},
    ~title="Manual",
    ~icon="fas fa-user",
    ~selected=true,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/courses/${courseId}/students/import`,
    ~title="CSV File Import",
    ~icon="fas fa-file",
    ~selected=false,
  ),
]

@react.component
let make = (~courseId) => {
  <div className="flex-1">
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/students`}
      title="Add new students"
      description={"You can add multiple students to a list and add them to course"}
      links={pageLinks(courseId)}
    />
    <div className="bg-white flex-1 pb-10">
      <div className="max-w-5xl mx-auto"> <StudentCreator__CreateForm courseId /> </div>
    </div>
  </div>
}

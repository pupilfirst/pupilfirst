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
      title="Edit Team"
      description={"Edit team {team name}"}
      links={pageLinks(courseId, studentId)}
    />
    <div className="max-w-5xl mx-auto px-2">
      <h2 className="text-lg font-semibold mt-8">{"Delete team Avengers" -> str}</h2>
      <p className="text-sm text-gray-500">{"Delete will remove all the students from the team and delete the team" -> str}</p>
      <button
        // onClick={}
        className="btn btn-danger mt-4">
          {"Delete team" -> str}
      </button>
    </div>
  </div>
}

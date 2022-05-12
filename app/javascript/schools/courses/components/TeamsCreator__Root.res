let str = React.string

@react.component
let make = (~courseId) => {
  <div>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/teams`}
      title="Add new teams"
      description={"You can add multiple students to a team."}
    />
    <div className="max-w-5xl mx-auto"> {str("Add team create form here!!")} </div>
  </div>
}

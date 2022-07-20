let str = React.string

@react.component
let make = (~courseId) => {
  <div>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/teams`}
      title="Create new team"
      description={"Course name"}
    />
    <AdminCoursesShared__TeamEditor courseId={courseId} />
  </div>
}

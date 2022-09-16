let str = React.string

@react.component
let make = (~courseId) => {
  let courseContext = React.useContext(SchoolRouter__CourseContext.context)
  <div>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/teams`}
      title="Create new team"
      description={courseContext.selectedCourse->Belt.Option.mapWithDefault(
        "Course",
        AppRouter__Course.name,
      )}
    />
    <AdminCoursesShared__TeamEditor courseId={courseId} />
  </div>
}

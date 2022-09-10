let str = React.string

@react.component
let make = (~courseId) => {
  let courseContext = React.useContext(SchoolRouter__CourseContext.context)
  switch courseContext.selectedCourse {
  | Some(_course) =>
    <div>
      <School__PageHeader
        exitUrl={`/school/courses/${courseId}/cohorts`}
        title="Add new cohort"
        description={"Create a new cohort for the course."}
      />
      <AdminCoursesShared__CohortsEditor courseId />
    </div>
  | None => <ErrorState />
  }
}

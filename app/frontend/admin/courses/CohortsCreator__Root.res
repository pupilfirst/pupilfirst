let str = React.string

@react.component
let make = (~courseId) => {
  <>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/cohorts`}
      title="Add new cohort"
      description={"Create a new cohort for the course."}
    />
    <AdminCoursesShared__CohortsEditor courseId />
  </>
}

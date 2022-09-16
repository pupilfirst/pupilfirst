let str = React.string

let t = I18n.t(~scope="components.CohortsCreator__Root")

@react.component
let make = (~courseId) => {
  <>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/cohorts`}
      title={t("page_title")}
      description={t("page_description")}
    />
    <AdminCoursesShared__CohortsEditor courseId />
  </>
}

let str = React.string

let t = I18n.t(~scope="components.StudentCreator__Root")

let pageLinks = courseId => [
  School__PageHeader.makeLink(
    ~href={`/school/courses/${courseId}/students/new`},
    ~title=t("pages.manual"),
    ~icon="fas fa-user",
    ~selected=true,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/courses/${courseId}/students/import`,
    ~title=t("pages.csv_import"),
    ~icon="fas fa-file",
    ~selected=false,
  ),
]

@react.component
let make = (~courseId) => {
  <div className="flex-1">
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/students`}
      title={t("page_title")}
      description={t("page_description")}
      links={pageLinks(courseId)}
    />
    <div className="bg-white flex-1 pb-10">
      <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4">
        <StudentCreator__CreateForm courseId />
      </div>
    </div>
  </div>
}

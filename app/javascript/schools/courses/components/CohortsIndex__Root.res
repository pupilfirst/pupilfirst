let str = React.string

let makeFilters = () => {
  [
    CourseResourcesFilter.makeFilter("include", "Include", Custom("Inactive Cohorts"), "orange"),
    CourseResourcesFilter.makeFilter("name", "Search by Team Name", Search, "gray"),
  ]
}

@react.component
let make = (~courseId, ~search) => {
  <>
    <Helmet> <title> {str("Cohorts Index")} </title> </Helmet>
    <div>
      <div>
        <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4">
          <div className="mt-2 text-right flex space-x-2">
            <Link
              className="btn btn-primary btn-large"
              href={`/school/courses/${courseId}/cohorts/new`}>
              <span> {str("Create Cohort")} </span>
            </Link>
            <Link
              className="btn btn-primary btn-large"
              href={`/school/courses/${courseId}/cohorts/1/details`}>
              <span> {str("Cohort Details")} </span>
            </Link>
          </div>
          <ul className="flex font-semibold text-sm">
            <li className="px-3 py-3 md:py-2 text-primary-500 border-b-3 border-primary-500 -mb-px">
              <span> {"Active Cohorts"->str} </span>
            </li>
          </ul>
          <div className="bg-gray-100 sticky top-0 py-3">
            <div className="border rounded-lg mx-auto bg-white ">
              <div>
                <div className="flex w-full items-start p-4">
                  <CourseResourcesFilter courseId filters={makeFilters()} search={search} />
                </div>
              </div>
            </div>
          </div>
          <div> {"add cohorts index here"->str} </div>
        </div>
      </div>
    </div>
  </>
}

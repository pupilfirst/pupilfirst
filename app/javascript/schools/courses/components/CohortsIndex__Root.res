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
        <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4 mt-8">
          <div className="mt-2 flex gap-2 items-center justify-between">
            <div>
              <ul className="flex font-semibold text-sm">
                <li
                  className="px-3 py-3 md:py-2 text-primary-500 border-b-3 border-primary-500 -mb-px">
                  {"Active Cohorts"->str}
                </li>
              </ul>
            </div>
            <Link
              className="btn btn-primary btn-large"
              href={`/school/courses/${courseId}/cohorts/new`}>
              <PfIcon className="if i-plus-circle-light if-fw" />
              <span className="inline-block pl-2"> {str("Add new cohort")} </span>
            </Link>
          </div>
          <div className="sticky top-0 my-6">
            <div className="border rounded-lg mx-auto bg-white ">
              <div>
                <div className="flex w-full items-start p-4">
                  <CourseResourcesFilter courseId filters={makeFilters()} search={search} />
                </div>
              </div>
            </div>
          </div>
          <div className="p-6 bg-white rounded-lg">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-xl font-semibold"> {"Cohort name"->str} </h2>
                <p className="text-sm text-gray-500"> {"Cohort description"->str} </p>
              </div>
              <div>
                <Link
                  href={`/school/courses/${courseId}/cohorts/1/details`}
                  className="block px-3 py-2 bg-grey-50 text-sm text-grey-600 border rounded border-gray-300 hover:bg-primary-100 hover:text-primary-500 hover:border-primary-500 focus:outline-none focus:bg-primary-100 focus:text-primary-500 focus:ring-2 focus:ring-focusColor-500">
                  <span className="inline-block pr-2"> <i className="fas fa-edit" /> </span>
                  <span> {"Edit"->str} </span>
                </Link>
              </div>
            </div>
            <div className="flex gap-6 flex-wrap mt-6">
              <div>
                <p className="pr-6 text-sm text-gray-500 font-medium"> {"Students"->str} </p>
                <p className="pr-3 mt-2 border-r-2 border-gray-200 font-semibold"> {"0"->str} </p>
              </div>
              <div>
                <p className="pr-6 text-sm text-gray-500 font-medium"> {"Coaches"->str} </p>
                <p className="pr-3 mt-2 border-r-2 border-gray-200 font-semibold"> {"0"->str} </p>
              </div>
              <div>
                <p className="pr-6 text-sm text-gray-500 font-medium"> {"Cohort end date"->str} </p>
                <p className="pr-3 mt-2 border-r-2 border-gray-200 font-semibold">
                  {"-----"->str}
                </p>
              </div>
              <div>
                <p className="pr-6 text-xs text-gray-500 font-medium">
                  {"Linked calendars"->str}
                </p>
                <p className="pr-3 mt-2 font-semibold">
                  <a className="text-primary-500 hover:text-primary-700" href="#">
                    {"Main calendar"->str}
                  </a>
                </p>
              </div>
            </div>
            <div />
          </div>
        </div>
      </div>
    </div>
  </>
}

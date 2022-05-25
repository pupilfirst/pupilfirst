let str = React.string

let makeFilters = () => {
  [
    CourseResourcesFilter.makeFilter("cohort", "Cohort", DataLoad(#Cohort), "green"),
    CourseResourcesFilter.makeFilter("include", "Include", Custom("Inactive Teams"), "orange"),
    CourseResourcesFilter.makeFilter("name", "Search by Team Name", Search, "gray"),
  ]
}

let studentCard = _ =>
  <div className="flex gap-4 items-center p-4 rounded-lg bg-white border border-gray-200 ">
    <div> <Avatar name={"Vincent harvy"} className="w-10 h-10 rounded-full" /> </div>
    <div>
      <p className="text-sm font-semibold mb-2"> {"Vincent harvy"->str} </p>
      <div className="flex gap-2 flex-wrap">
        {["Tag 1", "Tag 2"]
        ->Js.Array2.map(tag =>
          <p className="px-2 py-1 text-xs bg-gray-50 text-gray-500 rounded-2xl "> {tag->str} </p>
        )
        ->React.array}
      </div>
    </div>
  </div>

@react.component
let make = (~courseId, ~search) => {
  <>
    <Helmet> <title> {str("Teams Index")} </title> </Helmet>
    <div>
      <div>
        <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4 mt-8">
          <div className="mt-2 flex gap-2 items-center justify-between">
            <ul className="flex font-semibold text-sm">
              <li
                className="px-3 py-3 md:py-2 text-primary-500 border-b-3 border-primary-500 -mb-px">
                {"Active Teams"->str}
              </li>
            </ul>
            <Link className="btn btn-primary" href={`/school/courses/${courseId}/teams/new`}>
              <PfIcon className="if i-plus-circle-light if-fw" />
              <span className="inline-block pl-2"> {str("Create Team")} </span>
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
              <div className="flex items-center gap-3">
                <p className="text-lg font-semibold"> {"Name of team"->str} </p>
                <p className="px-3 py-2 text-xs bg-green-50 text-green-500 rounded-2xl ">
                  {"Cohort name"->str}
                </p>
              </div>
              <Link
                href={`/school/courses/${courseId}/teams/1/details`}
                className="block px-3 py-2 bg-grey-50 text-sm text-grey-600 border rounded border-gray-300 hover:bg-primary-100 hover:text-primary-500 hover:border-primary-500 focus:outline-none focus:bg-primary-100 focus:text-primary-500 focus:ring-2 focus:ring-focusColor-500">
                <span className="inline-block pr-2"> <i className="fas fa-edit" /> </span>
                <span> {"Edit"->str} </span>
              </Link>
            </div>
            <div className="grid grid-cols-1 gap-4 mt-6 lg md:grid-cols-2"> {studentCard()} </div>
          </div>
        </div>
      </div>
    </div>
  </>
}

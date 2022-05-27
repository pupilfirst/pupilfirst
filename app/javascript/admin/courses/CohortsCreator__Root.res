let str = React.string

@react.component
let make = (~courseId) => {
  let (cohortName, setCohortName) = React.useState(_ => "")
  let (cohortDescription, setCohortDescription) = React.useState(_ => "")

  <div>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/cohorts`}
      title="Add new cohort"
      description={"{{Course name}}"}
    />
    <div className="max-w-5xl mx-auto">
      <form className="max-w-5xl mx-auto px-2">
        <div className="mt-8">
          <label className="block text-sm font-semibold mb-2" htmlFor="cohortName">
            {"Cohort name" |> str}
          </label>
          <input
            value={cohortName}
            onChange={event => setCohortName(ReactEvent.Form.target(event)["value"])}
            className="appearance-none block w-full text-sm bg-white border border-gray-300 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:ring-2 focus:ring-focusColor-500"
            id="cohortName"
            type_="text"
            placeholder="eg, Batch 1"
          />
          // <School__InputGroupError
          //   message="Enter a valid team name"
          //   active={}
          // />
        </div>
        <div className="mt-6">
          <label className="block text-sm font-semibold mb-2" htmlFor="cohortDescription">
            {"Cohort description" |> str}
          </label>
          <input
            value={cohortDescription}
            onChange={event => setCohortDescription(ReactEvent.Form.target(event)["value"])}
            className="appearance-none block w-full text-sm bg-white border border-gray-300 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:ring-2 focus:ring-focusColor-500"
            id="cohortDescription"
            type_="text"
            placeholder="eg, Batch 1 of some year"
          />
          // <School__InputGroupError
          //   message="Enter a valid team name"
          //   active={}
          // />
        </div>
        <div className="mt-6">
          <div className="flex">
            <label className="block text-sm font-semibold mb-2" htmlFor="cohortName">
              {"Cohort end date" |> str}
              <span className="text-xs ml-1 font-light"> {"(optional)"->str} </span>
            </label>
            <HelpIcon className="ml-1 text-sm">
              {"The cohort will be archived on this date"->str}
            </HelpIcon>
          </div>
          // <DatePicker
          //   id="cohort-end-date"
          //   onChange={}
          //   selected={}
          // />
          // <School__InputGroupError
          //   message="Enter a valid team name"
          //   active={}
          // />
        </div>
        <button className="btn btn-primary btn-large w-full mt-6" type_="submit">
          {"Add new cohort"->str}
        </button>
      </form>
    </div>
  </div>
}

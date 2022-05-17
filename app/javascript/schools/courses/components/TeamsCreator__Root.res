let str = React.string


// MOCK DATA

type cohort = {
  id: string,
  name: string
}

let cohorts = [
  {id:"1", name: "Cohort 1"},
  {id:"2", name: "Cohort 2"},
  {id:"3", name: "Cohort 3"}
]

// ----------------

let formInvalid = (teamName, selectedCohort) =>
  teamName == "" || selectedCohort == ""


@react.component
let make = (~courseId) => {
  let (teamName, setTeamName) = React.useState(_ => "")
  let (selectedCohort, setSelectedCohort) = React.useState(_ => "")

  <div>
    <School__PageHeader
      exitUrl={`/school/courses/${courseId}/teams`}
      title="Create new team"
      description={"Course name"}
    />
    <form className="max-w-5xl mx-auto px-2">
      <div className="mt-8">
        <label
          className="block text-sm font-semibold mb-2"
          htmlFor="teamName">
          {"Team name" |> str}
        </label>
        <input
          value={teamName}
          onChange={event => setTeamName(ReactEvent.Form.target(event)["value"])}
          className="appearance-none block w-full text-sm bg-white border border-gray-300 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:ring-2 focus:ring-focusColor-500"
          id="teamName"
          type_="text"
          placeholder="eg, Avengers"
        />
        // <School__InputGroupError
        //   message="Enter a valid team name"
        //   active={}
        // />
      </div>
      <div className="mt-6">
        <label
          className="block text-sm font-semibold mb-2"
          htmlFor="cohort">
          {"Select cohort" |> str}
        </label>
        <select
          id="cohort"
          value={selectedCohort}
          onChange={event => {
            setSelectedCohort(ReactEvent.Form.target(event)["value"])
          }}
          className="select appearance-none block text-sm w-full bg-white border border-gray-300 rounded px-3 py-2 focus:outline-none focus:border-transparent focus:ring-2 focus:ring-focusColor-500">
          {cohorts
          ->Js.Array2.map(cohort =>
            <option key=cohort.id value=cohort.id ariaSelected={selectedCohort===cohort.id}>
              {cohort.name->str}
            </option>
          )
          ->React.array}
          </select>
        // <School__InputGroupError
        //   message="Select a cohort"
        //   active={}
        // />

        {
          selectedCohort != ""
          ? {
            <div>
              <p>{"Replace with student selector" -> str}</p>
              <button
                // onClick={}
                disabled={formInvalid(teamName, selectedCohort)}
                className="btn btn-primary w-full mt-6"

                >{"create new team" -> str}
            </button>
          </div>
          }
          : React.null
        }
      </div>
    </form>
  </div>
}


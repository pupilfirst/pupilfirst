open CourseApplicants__Types

type state = {
  name: string,
  email: string,
  title: string,
  affiliation: string,
  hasNameError: bool,
  hasEmailError: bool,
  tagsToApply: array<string>,
  teamName: string,
}

type action =
  | UpdateName(string, bool)
  | UpdateEmail(string, bool)
  | UpdateTitle(string)
  | UpdateTeamName(string)
  | UpdateAffiliation(string)
  | ResetForm
  | AddTag(string)
  | RemoveTag(string)

let str = React.string

let updateName = (send, name) => {
  let hasError = name |> String.length < 2
  send(UpdateName(name, hasError))
}

let updateEmail = (send, email) => {
  let regex = %re(`/.+@.+\\..+/i`)
  let hasError = !Js.Re.test_(regex, email)
  send(UpdateEmail(email, hasError))
}

let formInvalid = state =>
  state.name == "" || (state.email == "" || (state.hasNameError || state.hasEmailError))

let initialState = applicant => {
  name: Applicant.name(applicant),
  email: Applicant.email(applicant),
  title: "",
  affiliation: "",
  hasNameError: false,
  hasEmailError: false,
  tagsToApply: Applicant.tags(applicant),
  teamName: "",
}

let reducer = (state, action) =>
  switch action {
  | UpdateName(name, hasNameError) => {...state, name: name, hasNameError: hasNameError}
  | UpdateEmail(email, hasEmailError) => {...state, email: email, hasEmailError: hasEmailError}
  | UpdateTitle(title) => {...state, title: title}
  | UpdateTeamName(teamName) => {...state, teamName: teamName}
  | UpdateAffiliation(affiliation) => {...state, affiliation: affiliation}
  | ResetForm => {
      ...state,
      name: "",
      email: "",
      hasNameError: false,
      hasEmailError: false,
    }
  | AddTag(tag) => {
      ...state,
      tagsToApply: state.tagsToApply |> Array.append([tag]),
    }
  | RemoveTag(tag) => {
      ...state,
      tagsToApply: state.tagsToApply |> Js.Array.filter(t => t != tag),
    }
  }

@react.component
let make = (~applicant, ~tags, ~updateApplicantCB) => {
  let (state, send) = React.useReducer(reducer, initialState(applicant))
  <div className="relative">
    <div className="mx-auto bg-white">
      <div className="max-w-2xl mx-auto">
        <div className="mt-5">
          <label className="inline-block tracking-wide text-xs font-semibold" htmlFor="name">
            {"Name" |> str}
          </label>
          <input
            value=state.name
            onChange={event => updateName(send, ReactEvent.Form.target(event)["value"])}
            className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
            id="name"
            type_="text"
            placeholder="Student name here"
          />
          <School__InputGroupError message="is not valid" active=state.hasNameError />
        </div>
        <div className="mt-5">
          <label className="inline-block tracking-wide text-xs font-semibold" htmlFor="email">
            {"Email" |> str}
          </label>
          <input
            value=state.email
            onChange={event => updateEmail(send, ReactEvent.Form.target(event)["value"])}
            className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
            id="email"
            type_="email"
            placeholder="Student email here"
          />
          <School__InputGroupError message={"invalid email"} active={state.hasEmailError} />
        </div>
        <div className="mt-5">
          <label
            className="inline-block tracking-wide text-xs font-semibold mb-2 leading-tight"
            htmlFor="title">
            {"Title" |> str}
          </label>
          <span className="text-xs ml-1"> {"(optional)" |> str} </span>
          <input
            value=state.title
            onChange={event => send(UpdateTitle(ReactEvent.Form.target(event)["value"]))}
            className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-gray-500"
            id="title"
            type_="text"
            placeholder="Student, Coach, CEO, etc."
          />
        </div>
        <div className="mt-5">
          <label
            className="inline-block tracking-wide text-xs font-semibold mb-2 leading-tight"
            htmlFor="affiliation">
            {"Affiliation" |> str}
          </label>
          <span className="text-xs ml-1"> {"(optional)" |> str} </span>
          <input
            value=state.affiliation
            onChange={event => send(UpdateAffiliation(ReactEvent.Form.target(event)["value"]))}
            className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-gray-500"
            id="affiliation"
            type_="text"
            placeholder="Acme Inc., Acme University, etc."
          />
        </div>
        <div className="mt-5">
          <label
            className="inline-block tracking-wide text-xs font-semibold mb-2 leading-tight"
            htmlFor="team_name">
            {"Team Name" |> str}
          </label>
          <span className="text-xs ml-1"> {"(optional)" |> str} </span>
          <HelpIcon className="ml-1">
            {"Students with same team name will be grouped together; this will not affect existing teams in the course." |> str}
          </HelpIcon>
          <input
            value=state.teamName
            onChange={event => send(UpdateTeamName(ReactEvent.Form.target(event)["value"]))}
            className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-gray-500"
            id="team_name"
            maxLength=50
            type_="text"
            placeholder="Avengers, Fantastic Four, etc."
          />
        </div>
        <div className="mt-5">
          <label className="inline-block tracking-wide text-xs font-semibold" htmlFor="tags">
            {"Tags" |> str}
          </label>
          <span className="text-xs ml-1"> {"(optional)" |> str} </span>
        </div>
        <School__SearchableTagList
          unselectedTags={Js.Array.filter(tag => !(state.tagsToApply |> Array.mem(tag)), tags)}
          selectedTags=state.tagsToApply
          addTagCB={tag => send(AddTag(tag))}
          removeTagCB={tag => send(RemoveTag(tag))}
          allowNewTags=true
        />
        <button
          disabled={formInvalid(state)}
          className={"btn btn-primary mt-5" ++ (formInvalid(state) ? " disabled" : "")}>
          {"Add to List" |> str}
        </button>
      </div>
    </div>
  </div>
}

open StudentsEditor__Types

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
  let hasError = Js.String2.length(name) < 2
  send(UpdateName(name, hasError))
}

let updateEmail = (send, email) => {
  let regex = %re(`/.+@.+\\..+/i`)
  let hasError = !Js.Re.test_(regex, email)
  send(UpdateEmail(email, hasError))
}

let hasEmailDuplication = (email, emailsToAdd) => {
  let lowerCaseEmail = Js.String2.toLowerCase(email)
  Js.Array2.some(emailsToAdd, emailToAdd => lowerCaseEmail == Js.String2.toLowerCase(emailToAdd))
}

let formInvalid = (state, emailsToAdd) =>
  state.name == "" ||
    (state.email == "" ||
    (state.hasNameError || (state.hasEmailError || hasEmailDuplication(state.email, emailsToAdd))))

let handleAdd = (state, send, emailsToAdd, addToListCB) => {
  let trimmedTeamName = Js.String2.trim(state.teamName)
  let teamName = trimmedTeamName == "" ? None : Some(trimmedTeamName)

  if !formInvalid(state, emailsToAdd) {
    addToListCB(
      StudentInfo.make(
        ~name=state.name,
        ~email=state.email,
        ~title=state.title,
        ~affiliation=state.affiliation,
      ),
      teamName,
      state.tagsToApply,
    )
    send(ResetForm)
  }
}

let initialState = () => {
  name: "",
  email: "",
  title: "",
  affiliation: "",
  hasNameError: false,
  hasEmailError: false,
  tagsToApply: [],
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
      tagsToApply: Js.Array2.concat(state.tagsToApply, [tag]),
    }
  | RemoveTag(tag) => {
      ...state,
      tagsToApply: Js.Array2.filter(state.tagsToApply, t => t != tag),
    }
  }

@react.component
let make = (~addToListCB, ~teamTags, ~emailsToAdd) => {
  let (state, send) = React.useReducer(reducer, initialState())
  <div className="bg-gray-100 p-4">
    <div>
      <label className="inline-block tracking-wide text-xs font-semibold" htmlFor="name">
        {"Name" |> str}
      </label>
      <input
        autoFocus=true
        value=state.name
        onChange={event => updateName(send, ReactEvent.Form.target(event)["value"])}
        className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-indigo-500"
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
        className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-indigo-500"
        id="email"
        type_="email"
        placeholder="Student email here"
      />
      <School__InputGroupError
        message={state.hasEmailError
          ? "invalid email"
          : switch hasEmailDuplication(state.email, emailsToAdd) {
            | true => "email address not unique for student"
            | false => ""
            }}
        active={state.hasEmailError || hasEmailDuplication(state.email, emailsToAdd)}
      />
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
        className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-indigo-500"
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
        className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-indigo-500"
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
        className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-indigo-500"
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
      unselectedTags={Js.Array2.filter(teamTags, tag =>
        !Js.Array2.includes(state.tagsToApply, tag)
      )}
      selectedTags=state.tagsToApply
      addTagCB={tag => send(AddTag(tag))}
      removeTagCB={tag => send(RemoveTag(tag))}
      allowNewTags=true
    />
    <button
      onClick={_e => handleAdd(state, send, emailsToAdd, addToListCB)}
      disabled={formInvalid(state, emailsToAdd)}
      className={"btn btn-primary mt-5" ++ (formInvalid(state, emailsToAdd) ? " disabled" : "")}>
      {"Add to List" |> str}
    </button>
  </div>
}

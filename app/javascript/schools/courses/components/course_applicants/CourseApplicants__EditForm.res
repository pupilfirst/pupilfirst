open CourseApplicants__Types

type tabs =
  | DetailsTab
  | ActionsTab

type state = {
  title: string,
  affiliation: string,
  hasNameError: bool,
  hasEmailError: bool,
  tagsToApply: array<string>,
  accessEndsAt: option<Js.Date.t>,
  saving: bool,
  notifyStudent: bool,
}

type action =
  | UpdateTitle(string)
  | UpdateAffiliation(string)
  | AddTag(string)
  | RemoveTag(string)
  | UpdateAccessEndsAt(option<Js.Date.t>)
  | StartSaving
  | FailSaving
  | ToggleNotifyStudent

module CreateStudentFromApplicant = %graphql(
  `
  mutation CreateStudentFromApplicant($applicantId: ID!, $notifyStudent: Boolean!, $accessEndsAt: ISO8601DateTime, $title: String, $affiliation: String, $tags: [String!]!) {
    createStudentFromApplicant(applicantId: $applicantId, notifyStudent: $notifyStudent, accessEndsAt: $accessEndsAt, title: $title, affiliation: $affiliation, tags: $tags) {
      success
    }
  }
  `
)

let updateCourse = (state, send, updateApplicantCB, applicant) => {
  send(StartSaving)

  let updateCourseQuery = CreateStudentFromApplicant.make(
    ~applicantId=Applicant.id(applicant),
    ~accessEndsAt=?state.accessEndsAt->Belt.Option.map(DateFns.encodeISO),
    ~title=state.title,
    ~affiliation=state.affiliation,
    ~notifyStudent=state.notifyStudent,
    ~tags=state.tagsToApply,
    (),
  )

  updateCourseQuery |> GraphqlQuery.sendQuery |> Js.Promise.then_(result => {
    result["createStudentFromApplicant"]["success"] ? updateApplicantCB() : send(FailSaving)
    Js.Promise.resolve()
  }) |> Js.Promise.catch(error => {
    Js.log(error)
    send(FailSaving)
    Js.Promise.resolve()
  }) |> ignore
}

let str = React.string

let initialState = applicant => {
  title: "",
  affiliation: "",
  hasNameError: false,
  hasEmailError: false,
  tagsToApply: Applicant.tags(applicant),
  accessEndsAt: None,
  notifyStudent: true,
  saving: false,
}

let reducer = (state, action) =>
  switch action {
  | UpdateTitle(title) => {...state, title: title}
  | UpdateAffiliation(affiliation) => {...state, affiliation: affiliation}
  | AddTag(tag) => {
      ...state,
      tagsToApply: Js.Array.concat([tag], state.tagsToApply),
    }
  | RemoveTag(tag) => {
      ...state,
      tagsToApply: Js.Array.filter(t => t != tag, state.tagsToApply),
    }
  | UpdateAccessEndsAt(accessEndsAt) => {...state, accessEndsAt: accessEndsAt}
  | StartSaving => {...state, saving: true}
  | FailSaving => {...state, saving: false}
  | ToggleNotifyStudent => {...state, notifyStudent: !state.notifyStudent}
  }

let selectedTabClasses = selected =>
  "flex items-center focus:outline-none justify-center w-1/2 p-3 font-semibold rounded-t-lg leading-relaxed border border-gray-400 text-gray-600 cursor-pointer " ++ (
    selected ? "text-primary-500 bg-white border-b-0" : "bg-gray-100"
  )

let tabItemsClasses = selected => selected ? "" : "hidden"

let detailsTab = (state, applicant) => {
  <div>
    <div className="mt-5">
      <label className="inline-block tracking-wide text-xs font-semibold" htmlFor="name">
        {"Name"->str}
      </label>
      <input
        value={Applicant.name(applicant)}
        disabled=true
        className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
        id="name"
        type_="text"
        placeholder="Student name here"
      />
      <School__InputGroupError message="is not valid" active=state.hasNameError />
    </div>
    <div className="mt-5">
      <label className="inline-block tracking-wide text-xs font-semibold" htmlFor="email">
        {"Email"->str}
      </label>
      <input
        value={Applicant.email(applicant)}
        disabled=true
        className="appearance-none block w-full bg-white border border-gray-400 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
        id="email"
        type_="email"
        placeholder="Student email here"
      />
    </div>
  </div>
}

let showActionsTab = (state, send, applicant, tags, updateApplicantCB) => {
  <div>
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
      <label className="tracking-wide text-xs font-semibold" htmlFor="access-ends-at-input">
        {"Student's Access Ends On" |> str}
      </label>
      <span className="ml-1 text-xs"> {"(optional)" |> str} </span>
      <HelpIcon
        className="ml-2" link="https://docs.pupilfirst.com/#/students?id=editing-student-details">
        {"If set, students will not be able to complete targets after this date." |> str}
      </HelpIcon>
      <DatePicker
        onChange={date => send(UpdateAccessEndsAt(date))}
        selected=?state.accessEndsAt
        id="access-ends-at-input"
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
    <div className="mt-4">
      <input
        onChange={_event => send(ToggleNotifyStudent)}
        checked=state.notifyStudent
        className="hidden checkbox-input"
        id="notify-new-students"
        type_="checkbox"
      />
      <label className="checkbox-label" htmlFor="notify-new-students">
        <span>
          <svg width="12px" height="10px" viewBox="0 0 12 10">
            <polyline points="1.5 6 4.5 9 10.5 1" />
          </svg>
        </span>
        <span className="text-sm">
          {" Notify students, and send them a link to sign into this school."->str}
        </span>
      </label>
    </div>
    <button
      disabled={state.saving}
      className={"btn btn-primary mt-5"}
      onClick={_ => updateCourse(state, send, updateApplicantCB, applicant)}>
      {"Add as student" |> str}
    </button>
  </div>
}

@react.component
let make = (~applicant, ~tags, ~updateApplicantCB, ~selectedTab, ~baseUrl) => {
  let (state, send) = React.useReducer(reducer, initialState(applicant))
  Js.log(tags)
  <div className="relative">
    <div className="mx-auto bg-white">
      <div className="max-w-2xl mx-auto">
        <div className="mt-5">
          <h5 className="uppercase text-center"> {"Add as a student"->str} </h5>
        </div>
        <div className="w-full pt-6">
          <div className="flex flex-wrap w-full max-w-3xl mx-auto text-sm px-3 -mb-px">
            <button
              className={selectedTabClasses(selectedTab == DetailsTab)}
              onClick={_ => ReasonReactRouter.push(baseUrl ++ applicant.id ++ "/details")}>
              <i className="fa fa-edit" /> <span className="ml-2"> {"Details"->str} </span>
            </button>
            <button
              className={"-ml-px " ++ selectedTabClasses(selectedTab == ActionsTab)}
              onClick={_ => ReasonReactRouter.push(baseUrl ++ applicant.id ++ "/actions")}>
              <i className="fa fa-cog" /> <span className="ml-2"> {"Actions"->str} </span>
            </button>
          </div>
          {switch selectedTab {
          | DetailsTab => detailsTab(state, applicant)
          | ActionsTab => showActionsTab(state, send, applicant, tags, updateApplicantCB)
          }}
        </div>
      </div>
    </div>
  </div>
}

open CourseApplicants__Types

let t = I18n.t(~scope="components.CourseApplicants__EditForm")

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

module CreateStudentFromApplicant = %graphql(`
  mutation CreateStudentFromApplicant($applicantId: ID!, $notifyStudent: Boolean!, $accessEndsAt: ISO8601DateTime, $title: String, $affiliation: String, $tags: [String!]!) {
    createStudentFromApplicant(applicantId: $applicantId, notifyStudent: $notifyStudent, accessEndsAt: $accessEndsAt, title: $title, affiliation: $affiliation, tags: $tags) {
      success
    }
  }
  `)

let updateCourse = (state, send, updateApplicantCB, applicant) => {
  send(StartSaving)

  let variables = CreateStudentFromApplicant.makeVariables(
    ~applicantId=Applicant.id(applicant),
    ~accessEndsAt=?state.accessEndsAt->Belt.Option.map(DateFns.encodeISO),
    ~title=state.title,
    ~affiliation=state.affiliation,
    ~notifyStudent=state.notifyStudent,
    ~tags=state.tagsToApply,
    (),
  )

  CreateStudentFromApplicant.fetch(variables)
  |> Js.Promise.then_((result: CreateStudentFromApplicant.t) => {
    result.createStudentFromApplicant.success ? updateApplicantCB() : send(FailSaving)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(error => {
    Js.log(error)
    send(FailSaving)
    Js.Promise.resolve()
  })
  |> ignore
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
  "flex items-center focus:outline-none justify-center w-1/2 p-3 font-semibold rounded-t-lg leading-relaxed border border-gray-300 text-gray-600 cursor-pointer " ++ (
    selected ? "text-primary-500 bg-white border-b-0" : "bg-gray-50"
  )

let tabItemsClasses = selected => selected ? "" : "hidden"

let detailsTab = (state, applicant) => {
  <div>
    <div className="mt-5">
      <label className="inline-block tracking-wide text-xs font-semibold" htmlFor="name">
        {t("name.label")->str}
      </label>
      <input
        autoFocus=true
        value={Applicant.name(applicant)}
        disabled=true
        className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
        id="name"
        type_="text"
        placeholder={t("name.placeholder")}
      />
      <School__InputGroupError message={t("name.error")} active=state.hasNameError />
    </div>
    <div className="mt-5">
      <label className="inline-block tracking-wide text-xs font-semibold" htmlFor="email">
        {t("email.label")->str}
      </label>
      <input
        value={Applicant.email(applicant)}
        disabled=true
        className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 mt-2 leading-tight focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
        id="email"
        type_="email"
        placeholder={t("email.placeholder")}
      />
    </div>
  </div>
}

let optionalText = () => {
  <span className="text-xs ml-1"> {("(" ++ I18n.ts("optional") ++ ")")->str} </span>
}

let showActionsTab = (state, send, applicant: Applicant.t, tags, updateApplicantCB) => {
  <div>
    <div className="mt-5">
      <label
        className="inline-block tracking-wide text-xs font-semibold mb-2 leading-tight"
        htmlFor="title">
        {t("title.label")->str}
      </label>
      {optionalText()}
      <input
        value=state.title
        onChange={event => send(UpdateTitle(ReactEvent.Form.target(event)["value"]))}
        className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
        id="title"
        type_="text"
        placeholder={t("title.placeholder")}
      />
    </div>
    <div className="mt-5">
      <label
        className="inline-block tracking-wide text-xs font-semibold mb-2 leading-tight"
        htmlFor="affiliation">
        {t("affiliation.label")->str}
      </label>
      {optionalText()}
      <input
        value=state.affiliation
        onChange={event => send(UpdateAffiliation(ReactEvent.Form.target(event)["value"]))}
        className="appearance-none block w-full bg-white border border-gray-300 rounded py-3 px-4 leading-snug focus:outline-none focus:bg-white focus:border-transparent focus:ring-2 focus:ring-focusColor-500"
        id="affiliation"
        type_="text"
        placeholder={t("affiliation.placeholder")}
      />
    </div>
    <div className="mt-5">
      <label className="tracking-wide text-xs font-semibold" htmlFor="access-ends-at-input">
        {t("access_ends_at.label")->str}
      </label>
      {optionalText()}
      <HelpIcon className="ml-2" link={t("access_ends_at.help_url")}>
        {t("access_ends_at.help")->str}
      </HelpIcon>
      <DatePicker
        onChange={date => send(UpdateAccessEndsAt(date))}
        selected=?state.accessEndsAt
        id="access-ends-at-input"
      />
    </div>
    <div className="mt-5">
      <label className="inline-block tracking-wide text-xs font-semibold" htmlFor="tags">
        {t("tags.label")->str}
      </label>
      {optionalText()}
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
        <span className="text-sm"> {t("notify_students.label")->str} </span>
      </label>
    </div>
    <button
      disabled={state.saving}
      className={"btn btn-primary mt-5"}
      onClick={_ => updateCourse(state, send, updateApplicantCB, applicant)}>
      {t("add_as_student_button") |> str}
    </button>
  </div>
}

@react.component
let make = (~applicant, ~tags, ~updateApplicantCB, ~selectedTab, ~baseUrl) => {
  let (state, send) = React.useReducer(reducer, initialState(applicant))

  <div className="relative">
    <div className="mx-auto bg-white">
      <div className="max-w-2xl mx-auto">
        <div className="mt-5">
          <h5 className="uppercase text-center"> {t("page_title")->str} </h5>
        </div>
        <div className="w-full pt-6">
          <div className="flex flex-wrap w-full max-w-3xl mx-auto text-sm px-3 -mb-px">
            <button
              className={selectedTabClasses(selectedTab == DetailsTab)}
              onClick={_ =>
                RescriptReactRouter.push(baseUrl ++ Applicant.id(applicant) ++ "/details")}>
              <i className="fa fa-edit" /> <span className="ml-2"> {t("tabs.details")->str} </span>
            </button>
            <button
              className={"-ml-px " ++ selectedTabClasses(selectedTab == ActionsTab)}
              onClick={_ =>
                RescriptReactRouter.push(baseUrl ++ Applicant.id(applicant) ++ "/actions")}>
              <i className="fa fa-cog" /> <span className="ml-2"> {t("tabs.actions")->str} </span>
            </button>
          </div>
          <Spread props={"applicant-id": Applicant.id(applicant)}>
            {switch selectedTab {
            | DetailsTab => detailsTab(state, applicant)
            | ActionsTab => showActionsTab(state, send, applicant, tags, updateApplicantCB)
            }}
          </Spread>
        </div>
      </div>
    </div>
  </div>
}

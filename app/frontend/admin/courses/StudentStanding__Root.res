@module("../../../assets/images/users/standing/no_standing_log.svg")
external noStandingLog: string = "default"

let t = I18n.t(~scope="components.StudentStanding__Root")
let ts = I18n.ts
let str = React.string

type student = {
  userId: string,
  name: string,
  email: string,
}

type userStanding = {
  id: string,
  standingName: string,
  standingColor: string,
  createdAt: Js.Date.t,
  creatorName: string,
  reason: string,
}

type userStandings = array<userStanding>

type standing = {
  id: string,
  name: string,
  color: string,
  description: option<string>,
}

type currentStanding = {
  color: string,
  name: string,
}

type standings = array<standing>

type pageData = {
  student: student,
  courseId: string,
  schoolStandingEnabled: bool,
}

type baseData = {
  userStandings: userStandings,
  standings: standings,
  currentStanding: currentStanding,
}

type standingData = Unloaded | Loading | Loaded(baseData) | Errored | NotFound

type state = {
  standingData: standingData,
  archive: bool,
  reason: string,
  select: string,
  pageData: pageData,
}

type action =
  | SetStandingData(standingData)
  | SetArchive(bool)
  | SetReason(string)
  | SetSelect(string)
  | SetPageData(pageData)

let reducer = (state, action) =>
  switch action {
  | SetStandingData(standingData) => {...state, standingData}
  | SetArchive(archive) => {...state, archive}
  | SetReason(reason) => {...state, reason}
  | SetSelect(select) => {...state, select}
  | SetPageData(pageData) => {...state, pageData}
  }

let pageLinks = studentId => [
  School__PageHeader.makeLink(
    ~href={`/school/students/${studentId}/details`},
    ~title=t("pages.details"),
    ~icon="if i-edit-regular text-base font-bold",
    ~selected=false,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/students/${studentId}/actions`,
    ~title=t("pages.actions"),
    ~icon="if i-cog-regular text-base font-bold",
    ~selected=false,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/students/${studentId}/standing`,
    ~title=t("pages.standing"),
    ~icon="if i-shield-regular text-base font-bold",
    ~selected=true,
  ),
]

module UserStandingFragment = %graphql(`
  fragment UserStandingFragment on UserStanding {
    id
    standingName
    standingColor
    createdAt
    creatorName
    reason
  }
`)

let makeFromUserStandingFragment = (userStanding: UserStandingFragment.t) => {
  id: userStanding.id,
  standingName: userStanding.standingName,
  standingColor: userStanding.standingColor,
  createdAt: userStanding.createdAt->DateFns.decodeISO,
  creatorName: userStanding.creatorName,
  reason: userStanding.reason,
}

module SchoolAndStudentDataQuery = %graphql(`
  query SchoolAndStudentDataQuery($studentId: ID!) {
    student(studentId: $studentId) {
      user {
        id
        name
        email
      }
      course {
        id
      }
    }
    isSchoolStandingEnabled
  }
`)

module StandingDataQuery = %graphql(`
  query StandingDataQuery($userId: ID!) {
    userStandings(userId: $userId) {
      ...UserStandingFragment
    }
    standings {
      id
      name
      color
      description
    }
  }
`)

module ArchiveUserStandingMutation = %graphql(`
  mutation archiveUserStandingMutation($id: ID!) {
    archiveUserStanding(id: $id) {
      success
    }
  }
`)

module CreateUserStandingMutation = %graphql(`
    mutation createUserStandingMutation($userId: ID!, $reason: String!, $standingId: ID!) {
      createUserStanding(userId: $userId, reason: $reason, standingId: $standingId) {
        userStanding {
          ...UserStandingFragment
        }
      }
    }
  `)

let addEntry = (userId, send, reason, standingId, baseData) => {
  CreateUserStandingMutation.fetch({
    userId,
    reason,
    standingId,
  })
  ->Js.Promise2.then((response: CreateUserStandingMutation.t) => {
    let log =
      response.createUserStanding.userStanding->Belt.Option.map(makeFromUserStandingFragment)
    switch log {
    | Some(log) =>
      send(
        SetStandingData(
          Loaded({
            userStandings: Js.Array2.concat([log], baseData.userStandings),
            standings: baseData.standings,
            currentStanding: {
              color: log.standingColor,
              name: log.standingName,
            },
          }),
        ),
      )
      send(SetReason(""))
      send(SetSelect("0"))
    | None => ()
    }
    Js.Promise.resolve()
  })
  ->Js.Promise2.catch(_error => {
    send(SetStandingData(Errored))
    Js.Promise.resolve()
  })
  ->ignore
}

let updateCurrentStanding = (userStandings: userStandings, standings: standings) => {
  switch userStandings->Js.Array2.length {
  | 0 => {
      let standing = Js.Array2.unsafe_get(standings, 0)
      {
        color: standing.color,
        name: standing.name,
      }
    }
  | _ => {
      let standing = Js.Array2.unsafe_get(userStandings, 0)
      {
        color: standing.standingColor,
        name: standing.standingName,
      }
    }
  }
}

let loadStandingData = (userId, send) => {
  send(SetStandingData(Loading))
  StandingDataQuery.fetch(~notifyOnNotFound=false, {userId: userId})
  ->Js.Promise2.then((response: StandingDataQuery.t) => {
    let userStandings = response.userStandings->Js.Array2.map(makeFromUserStandingFragment)

    let standings = response.standings->Js.Array2.map(standing => {
      id: standing.id,
      name: standing.name,
      color: standing.color,
      description: standing.description,
    })

    send(
      SetStandingData(
        Loaded({
          userStandings,
          standings,
          currentStanding: updateCurrentStanding(userStandings, standings),
        }),
      ),
    )
    Js.Promise.resolve()
  })
  ->Js.Promise2.catch(_error => {
    send(SetStandingData(Errored))
    Js.Promise.resolve()
  })
  ->ignore
}

let loadPageData = (studentId, send, setCourseId) => {
  send(SetStandingData(Loading))
  SchoolAndStudentDataQuery.fetch({
    studentId: studentId,
  })
  ->Js.Promise2.then((response: SchoolAndStudentDataQuery.t) => {
    send(
      SetPageData({
        student: {
          userId: response.student.user.id,
          name: response.student.user.name,
          email: response.student.user.email,
        },
        courseId: response.student.course.id,
        schoolStandingEnabled: response.isSchoolStandingEnabled,
      }),
    )
    setCourseId(response.student.course.id)
    if response.isSchoolStandingEnabled {
      loadStandingData(response.student.user.id, send)
    } else {
      send(SetStandingData(NotFound))
    }
    Js.Promise.resolve()
  })
  ->Js.Promise2.catch(_error => {
    send(SetStandingData(Errored))
    Js.Promise.resolve()
  })
  ->ignore
}

let archiveStanding = (id: string, send, baseData, event) => {
  event->ReactEvent.Mouse.preventDefault

  if {
    open Webapi.Dom
    window->Window.confirm(t("confirm_delete"))
  } {
    send(SetArchive(true))
    ArchiveUserStandingMutation.fetch({
      id: id,
    })
    ->Js.Promise2.then((response: ArchiveUserStandingMutation.t) => {
      if response.archiveUserStanding.success {
        send(
          SetStandingData(
            Loaded({
              userStandings: Js.Array2.filter(baseData.userStandings, standing =>
                standing.id !== id
              ),
              standings: baseData.standings,
              currentStanding: updateCurrentStanding(
                Js.Array2.filter(baseData.userStandings, standing => standing.id !== id),
                baseData.standings,
              ),
            }),
          ),
        )
        send(SetArchive(false))
      } else {
        send(SetArchive(false))
      }
      Js.Promise.resolve()
    })
    ->Js.Promise2.catch(_error => {
      send(SetStandingData(Errored))
      Js.Promise.resolve()
    })
    ->ignore
  } else {
    ()
  }
}

let deleteIcon = (id: string, send, baseData) => {
  <button
    ariaLabel={t("delete_standing_log") ++ id}
    className="w-10 text-sm text-gray-600 cursor-pointer flex items-center justify-center rounded hover:bg-gray-50 hover:text-red-500 focus:outline-none focus:bg-gray-50 focus:text-red-500 focus:ring-2 focus:ring-inset focus:ring-red-500 "
    disabled={false}
    title={t("delete_standing_log") ++ id}
    onClick={archiveStanding(id, send, baseData)}>
    <PfIcon className="if i-trash-regular if-fw text-2xl" />
  </button>
}

let currentStandingCard = (standing: currentStanding) => {
  <div className="bg-white rounded-md p-8 border border-gray-200 shadow-lg" id="currentStanding">
    <div className="ml-4 flex flex-col">
      <p
        className="-mt-12 px-3 py-2 max-w-max text-xs bg-focusColor-50 border border-focusColor-200 text-focusColor-500 font-semibold rounded-full">
        {ts("user_standing.current_standing")->str}
      </p>
      <div className="flex flex-col justify-center items-center">
        <StandingShield color=standing.color sizeClass="w-16 h-16" />
        <div style={ReactDOM.Style.make(~color=standing.color, ())} className={`text-xl font-bold`}>
          {React.string(standing.name)}
        </div>
      </div>
    </div>
  </div>
}

let standingLogs = (userStandings: userStandings, send, baseData) => {
  let userStandingLogsCount = userStandings->Js.Array2.length
  <div className="mt-3">
    <h2 className="font-semibold text-lg mt-8"> {ts("user_standing.standing_log")->str} </h2>
    <div className="pt-4">
      {if userStandingLogsCount > 0 {
        userStandings
        ->Js.Array2.mapi((log, index) => {
          <div className="flex group" key={"Standing Log " ++ index->string_of_int}>
            <div className="p-2 h-full rounded-full bg-focusColor-50 z-10">
              <StandingShield color={log.standingColor} sizeClass="w-12 h-12" />
            </div>
            <div
              className={`-ml-8 pb-5 w-full pl-12 ${userStandingLogsCount > 1 &&
                  index !== userStandingLogsCount - 1
                  ? "border-l border-gray-300 border-dashed"
                  : ""} group-last:border-b-0`}>
              <div
                className="bg-white p-5 rounded-md border border-gray-200 flex items-center justify-between">
                <div>
                  <p
                    style={ReactDOM.Style.make(~color=log.standingColor, ())}
                    className="font-semibold">
                    {React.string(log.standingName)}
                  </p>
                  <p className="text-sm font-medium">
                    <PfIcon className="if i-calendar-light if-fw mr-1" />
                    {log.createdAt->DateFns.format("d MMMM yyyy")->str}
                    <span className="text-gray-500 mx-1"> {"•"->str} </span>
                    {log.createdAt->DateFns.format("h:mm a")->str}
                    <span className="ml-5">
                      <PfIcon className="if i-teacher-coach-regular if-fw mr-1" />
                      {log.creatorName->str}
                    </span>
                  </p>
                  <div className="text-sm mt-2 text-gray-500">
                    <MarkdownBlock profile=Markdown.Permissive markdown=log.reason />
                  </div>
                </div>
                <div className="ml-4"> {deleteIcon(log.id, send, baseData)} </div>
              </div>
            </div>
          </div>
        })
        ->React.array
      } else {
        <div className="flex flex-col items-center p-5 bg-white border border-gray-200 rounded-md ">
          <img className="w-20 h-20" src=noStandingLog />
          <p className="text-lg font-semibold"> {ts("user_standing.no_standing_log")->str} </p>
          <p className="text-sm text-gray-500"> {t("empty_standing_info")->str} </p>
        </div>
      }}
    </div>
  </div>
}

let addEntryButtonDisabled = (reason, select) => reason == "" || select == "0"

let editor = (send, state, baseData) => {
  <div className="pt-4">
    <h2 className="text-lg font-semibold"> {t("change_standing")->str} </h2>
    <p className="mb-4"> {t("change_standing_info")->str} </p>
    <div className="flex space-x-2 text-center items-center">
      <div className="relative">
        <select
          className="block appearance-none w-64 bg-gray-200 border border-gray-200 text-gray-700 py-2 px-4 pr-8 rounded leading-tight focus:outline-none focus:bg-white focus:border-gray-500 cursor-not-allowed"
          id="current-standing"
          disabled=true>
          <option key="0"> {baseData.currentStanding.name->str} </option>
        </select>
        <div
          className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
          <PfIcon className="if i-chevron-down-regular if-fw" />
        </div>
      </div>
      <div>
        <PfIcon className="if i-arrow-right-short-regular if-fw" />
      </div>
      <div className="relative">
        <select
          ariaLabel={t("select_standing")}
          className="block appearance-none w-64 bg-white border text-sm border-gray-300 rounded-s hover:border-gray-500 px-4 py-3 pe-8 rounded-e-none leading-tight focus:outline-none focus:ring-2 focus:ring-inset focus:ring-focusColor-500 cursor-pointer"
          id="change-standing"
          onChange={event => {
            let value = ReactEvent.Form.target(event)["value"]
            send(SetSelect(value))
          }}
          value=state.select>
          <option key="0" value="0"> {t("select_standing")->str} </option>
          {baseData.standings
          ->Js.Array2.map(standing => {
            <option key=standing.id value=standing.id title=standing.name>
              {standing.name->str}
            </option>
          })
          ->React.array}
        </select>
        <div
          className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
          <PfIcon className="if i-chevron-down-regular if-fw" />
        </div>
      </div>
    </div>
    {state.select != "0"
      ? <div className="text-yellow-900 text-sm font-inter mt-2 ps-72">
          <PfIcon className="if i-info-light if-fw" />
          {
            let description =
              Js.Array2.filter(baseData.standings, standing => standing.id == state.select)
              ->Js.Array2.unsafe_get(0)
              ->(standing => standing.description)

            {
              Belt.Option.getWithDefault(description, t("standing_description_missing"))
            }->str
          }
        </div>
      : React.null}
    <div className="mt-4">
      <label className="block text-sm font-medium text-gray-700 mb-2">
        {t("reason_heading")->str}
      </label>
      <div>
        <MarkdownEditor
          textareaId="reason-for-altering-standing"
          onChange={value => send(SetReason(value))}
          maxLength=1000
          value=state.reason
          profile=Markdown.Permissive
          placeholder={t("reason_placeholder")}
          fileUpload=false
          dynamicHeight=false
        />
      </div>
    </div>
    <div>
      <button
        className="mt-4 btn btn-primary btn-sm"
        disabled={addEntryButtonDisabled(state.reason, state.select)}
        onClick={_e => {
          addEntry(state.pageData.student.userId, send, state.reason, state.select, baseData)
        }}>
        {t("add_entry_button")->str}
      </button>
    </div>
  </div>
}

let schoolStandingDisabled = () => {
  <div className="flex flex-col items-center max-w-4xl 2xl:max-w-5xl mx-auto px-4 py-8">
    <img className="w-20 h-20" src=noStandingLog />
    <p className="text-lg font-semibold"> {t("school_standing_disabled")->str} </p>
    <p className="text-sm text-gray-500"> {t("contact_admin")->str} </p>
  </div>
}

let renderSchoolPageHeader = (studentId, studentName, studentEmail) => {
  <School__PageHeader
    exitUrl={`/school/students/${studentId}/details`}
    title={`${t("edit")} ${studentName}`}
    description={studentEmail}
    links={pageLinks(studentId)}
  />
}

@react.component
let make = (~studentId) => {
  let (state, send) = React.useReducer(
    reducer,
    {
      standingData: Unloaded,
      archive: false,
      reason: "",
      select: "0",
      pageData: {
        student: {
          userId: "",
          name: "",
          email: "",
        },
        courseId: "",
        schoolStandingEnabled: false,
      },
    },
  )

  let courseContext = React.useContext(SchoolRouter__CourseContext.context)

  React.useEffect1(() => {
    loadPageData(studentId, send, courseContext.setCourseId)
    None
  }, [studentId])

  switch state.standingData {
  | Unloaded
  | Loading =>
    SkeletonLoading.coursePage()
  | Loaded(baseData) =>
    <div>
      {renderSchoolPageHeader(studentId, state.pageData.student.name, state.pageData.student.email)}
      <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4 py-8">
        {currentStandingCard(baseData.currentStanding)}
        {standingLogs(baseData.userStandings, send, baseData)}
        {editor(send, state, baseData)}
      </div>
    </div>
  | Errored => <ErrorState />
  | NotFound =>
    <div>
      {renderSchoolPageHeader(studentId, state.pageData.student.name, state.pageData.student.email)}
      {schoolStandingDisabled()}
    </div>
  }
}

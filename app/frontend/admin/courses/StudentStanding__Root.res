@module("../../../assets/images/users/standing/no_standing_log.svg")
external noStandingLog: string = "default"

let t = I18n.t(~scope="components.StudentStanding__Root")
let ts = I18n.ts
let str = React.string

type student = {
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
  description: string,
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

let pageLinks = studentId => [
  School__PageHeader.makeLink(
    ~href={`/school/students/${studentId}/details`},
    ~title=t("pages.details"),
    ~icon="fas fa-edit",
    ~selected=false,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/students/${studentId}/actions`,
    ~title=t("pages.actions"),
    ~icon="fas fa-cog",
    ~selected=false,
  ),
  School__PageHeader.makeLink(
    ~href=`/school/students/${studentId}/standing`,
    ~title=t("pages.standing"),
    ~icon="if i-shield-regular text-base font-bold",
    ~selected=true,
  ),
]

type state = Unloaded | Loading | Loaded(baseData) | Errored | NotFound

module SchoolAndStudentDataQuery = %graphql(`
  query schoolAndStudentDataQuery($studentId: ID!) {
    student(studentId: $studentId) {
      user {
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

module StudentStandingDataQuery = %graphql(`
  query studentStandingDataQuery($studentId: ID!) {
    userStandings(studentId: $studentId) {
      id
      standingName
      standingColor
      createdAt
      creatorName
      reason
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

module CreateUserStadningMutation = %graphql(`
    mutation createUserStandingMutation($studentId: ID!, $reason: String!, $standingId: ID!) {
      createUserStanding(studentId: $studentId, reason: $reason, standingId: $standingId) {
        userStanding {
          id
          standingName
          standingColor
          reason
          createdAt
          creatorName
        }
      }
    }
  `)

let createUserStanding = (studentId, reason, standingId, setState, setReason, setSelect) => {
  CreateUserStadningMutation.fetch({studentId, reason, standingId})
  |> Js.Promise.then_((response: CreateUserStadningMutation.t) => {
    let log = response.createUserStanding.userStanding->Belt.Option.map(userStanding => {
      id: userStanding.id,
      standingName: userStanding.standingName,
      standingColor: userStanding.standingColor,
      createdAt: userStanding.createdAt->DateFns.decodeISO,
      creatorName: userStanding.creatorName,
      reason: userStanding.reason,
    })
    switch log {
    | Some(log) =>
      setReason(_ => "")
      setSelect(_ => "0")
      setState(currentState =>
        switch currentState {
        | Loaded(data) =>
          Loaded({
            ...data,
            userStandings: Js.Array2.concat([log], data.userStandings),
            currentStanding: {
              color: log.standingColor,
              name: log.standingName,
            },
          })
        | _ => currentState
        }
      )
    | None => ()
    }
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_error => {
    Js.Promise.resolve()
  })
  |> ignore
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

let loadStandingData = (studentId, setState) => {
  setState(_ => Loading)
  StudentStandingDataQuery.fetch(~notifyOnNotFound=false, {studentId: studentId})
  |> Js.Promise.then_((response: StudentStandingDataQuery.t) => {
    let userStandings = response.userStandings->Js.Array2.map(userStanding => {
      id: userStanding.id,
      standingName: userStanding.standingName,
      standingColor: userStanding.standingColor,
      createdAt: userStanding.createdAt->DateFns.decodeISO,
      creatorName: userStanding.creatorName,
      reason: userStanding.reason,
    })

    let standings = response.standings->Js.Array2.map(standing => {
      id: standing.id,
      name: standing.name,
      color: standing.color,
      description: standing.description,
    })

    setState(_ => Loaded({
      userStandings,
      standings,
      currentStanding: updateCurrentStanding(userStandings, standings),
    }))
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_error => {
    setState(_ => Errored)
    Js.Promise.resolve()
  })
  |> ignore
}

let loadPageData = (studentId, setState, setCourseId, setPageData) => {
  SchoolAndStudentDataQuery.fetch({
    studentId: studentId,
  })
  |> Js.Promise.then_((response: SchoolAndStudentDataQuery.t) => {
    setPageData(_ => {
      student: {
        name: response.student.user.name,
        email: response.student.user.email,
      },
      courseId: response.student.course.id,
      schoolStandingEnabled: response.isSchoolStandingEnabled,
    })
    setCourseId(response.student.course.id)
    if response.isSchoolStandingEnabled {
      loadStandingData(studentId, setState)
    } else {
      setState(_ => NotFound)
    }
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_error => {
    setState(_ => Errored)
    Js.Promise.resolve()
  })
  |> ignore
}

let archiveStanding = (id: string, setArchive, setState, event) => {
  event->ReactEvent.Mouse.preventDefault

  if {
    open Webapi.Dom
    window->Window.confirm(t("confirm_delete"))
  } {
    setArchive(_ => true)
    ArchiveUserStandingMutation.fetch({id: id})
    |> Js.Promise.then_((response: ArchiveUserStandingMutation.t) => {
      if response.archiveUserStanding.success {
        setState(currentState =>
          switch currentState {
          | Loaded(data) => {
              let userStandings =
                data.userStandings->Js.Array2.filter(standing => standing.id !== id)
              Loaded({
                ...data,
                userStandings,
                currentStanding: updateCurrentStanding(userStandings, data.standings),
              })
            }
          | _ => currentState
          }
        )
        setArchive(_ => false)
      } else {
        setArchive(_ => false)
      }
      Js.Promise.resolve()
    })
    |> ignore
  } else {
    ()
  }
}

let currentStandingCard = (standing: currentStanding) => {
  <div className="bg-white rounded-md p-8 border border-gray-100 shadow-lg" id="currentStanding">
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

let deleteIcon = (id: string, setArchive, archive, setState) => {
  <button
    ariaLabel={t("delete_standing_log") ++ id}
    className="w-10 text-sm text-gray-600 hover:text-gray-900 cursor-pointer flex items-center justify-center rounded hover:bg-gray-50 hover:text-red-500 focus:outline-none focus:bg-gray-50 focus:text-red-500 focus:ring-2 focus:ring-inset focus:ring-red-500 "
    disabled=archive
    title={t("delete_standing_log") ++ id}
    onClick={archiveStanding(id, setArchive, setState)}>
    <PfIcon className="if i-trash-regular if-fw text-2xl" />
  </button>
}

let standingLogs = (userStandings: userStandings, setArchive, archive, setState) => {
  let userStandingLogsCount = userStandings->Js.Array2.length
  <div className="mt-3">
    <h2 className="font-semibold text-lg mt-8"> {"Standing log"->str} </h2>
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
                <div className="ml-4"> {deleteIcon(log.id, setArchive, archive, setState)} </div>
              </div>
            </div>
          </div>
        })
        ->React.array
      } else {
        <div className="flex flex-col items-center p-5 bg-white border border-gray-200 rounded-md ">
          <img className="w-20 h-20" src=noStandingLog />
          <p className="text-lg font-semibold"> {ts("user_standing.no_standing_log")->str} </p>
          <p className="text-sm text-gray-500"> {ts("user_standing.empty_standing_info")->str} </p>
        </div>
      }}
    </div>
  </div>
}

let changeStandingButtonDisabled = (reason, select) => reason == "" || select == "0"

let editor = (
  standings,
  setReason,
  reason,
  setState,
  studentId,
  setSelect,
  select,
  currentStanding,
) => {
  <div className="pt-4">
    <h2 className="text-lg font-semibold"> {t("change_standing")->str} </h2>
    <p className="mb-4"> {t("change_standing_info")->str} </p>
    <div className="flex space-x-2 text-center items-center">
      <div className="relative">
        <select
          className="block appearance-none w-64 bg-gray-200 border border-gray-200 text-gray-700 py-2 px-4 pr-8 rounded leading-tight focus:outline-none focus:bg-white focus:border-gray-500 cursor-not-allowed"
          id="current-standing"
          disabled=true>
          <option key="0"> {currentStanding.name->str} </option>
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
            setSelect(_ => value)
          }}
          value=select>
          <option key="0" value="0"> {t("select_standing")->str} </option>
          {standings
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
    {select != "0"
      ? <div className="text-yellow-900 text-sm font-inter mt-2">
          <PfIcon className="if i-info-light if-fw" />
          {
            let description =
              Js.Array2.filter(standings, standing => standing.id == select)
              ->Js.Array2.unsafe_get(0)
              ->(standing => standing.description)

            {
              Js.String2.length(description) > 0
                ? description
                : "Selected Standing has no description"
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
          onChange={value => setReason(_ => value)}
          maxLength=250
          value=reason
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
        disabled={changeStandingButtonDisabled(reason, select)}
        onClick={_e => {
          createUserStanding(studentId, reason, select, setState, setReason, setSelect)
        }}>
        {t("change_standing")->str}
      </button>
    </div>
  </div>
}

let schoolStandingDisabled = () => {
  <div className="flex flex-col items-center max-w-4xl 2xl:max-w-5xl mx-auto px-4 py-8">
    <img className="w-20 h-20" src=noStandingLog />
    <p className="text-lg font-semibold"> {"School Standing is disabled"->str} </p>
    <p className="text-sm text-gray-500"> {"Please contact your school admin"->str} </p>
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
  let (state, setState) = React.useState(() => Unloaded)
  let (archive, setArchive) = React.useState(() => false)
  let (reason, setReason) = React.useState(() => "")
  let (select, setSelect) = React.useState(() => "0")
  let (pageData, setPageData) = React.useState(() => {
    student: {
      name: "",
      email: "",
    },
    courseId: "",
    schoolStandingEnabled: false,
  })

  let courseContext = React.useContext(SchoolRouter__CourseContext.context)

  React.useEffect1(() => {
    loadPageData(studentId, setState, courseContext.setCourseId, setPageData)
    None
  }, [studentId])

  switch state {
  | Unloaded
  | Loading =>
    SkeletonLoading.coursePage()
  | Loaded(baseData) =>
    <div>
      {renderSchoolPageHeader(studentId, pageData.student.name, pageData.student.email)}
      <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4 py-8">
        {currentStandingCard(baseData.currentStanding)}
        {standingLogs(baseData.userStandings, setArchive, archive, setState)}
        {editor(
          baseData.standings,
          setReason,
          reason,
          setState,
          studentId,
          setSelect,
          select,
          baseData.currentStanding,
        )}
      </div>
    </div>
  | Errored => <ErrorState />
  | NotFound =>
    <div>
      {renderSchoolPageHeader(studentId, pageData.student.name, pageData.student.email)}
      {schoolStandingDisabled()}
    </div>
  }
}

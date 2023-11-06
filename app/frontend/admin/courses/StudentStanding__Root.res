let t = I18n.t(~scope="components.StudentDetails__Root")
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
  description: option<string>,
}

type currentStanding = {
  color: string,
  name: string,
}

type standings = array<standing>

type baseData = {
  student: student,
  userStandings: userStandings,
  courseId: string,
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

type state = Unloaded | Loading | Loaded(baseData) | Errored

module StudentStandingDataQuery = %graphql(`
  query studentStandingDataQuery($studentId: ID!) {
    student(studentId: $studentId) {
      user {
        name
        email
      }
      course {
        id
      }
    }
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

let createUserStanding = (studentId, reason, standingId, setState, setReason, setStanding) => {
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
      setStanding(_ => "0")
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

let loadData = (studentId, setState, setCourseId) => {
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
      student: {
        name: response.student.user.name,
        email: response.student.user.email,
      },
      userStandings,
      courseId: response.student.course.id,
      standings,
      currentStanding: updateCurrentStanding(userStandings, standings),
    }))
    setCourseId(response.student.course.id)
    Js.Promise.resolve()
  })
  |> Js.Promise.catch(_error => {
    setState(_ => Errored)
    Js.Promise.resolve()
  })
  |> ignore
}

let archiveStanding = (id: string, setArchive, setState, event) => {
  event |> ReactEvent.Mouse.preventDefault

  if {
    open Webapi.Dom
    window->Window.confirm(t("sure_delete"))
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

let shieldIcon = color => {
  <svg
    className="if-svg-icon__baseline i-shield-solid if-fw text-5xl if-w-16 if-h-16"
    role="img"
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 512 512">
    <path
      fill=color
      d="M85.26,114.03L246.17,47.16c6.29-2.61,13.36-2.61,19.65,0l160.91,66.87c9.56,3.97,15.78,13.27,15.78,23.61v112.13c0,58.34-62.66,159.98-175.83,214.66-6.73,3.25-14.6,3.13-21.26-.23-123.01-62.15-175.93-155.93-175.93-214.43v-112.13c0-10.34,6.22-19.65,15.77-23.61Z"
    />
  </svg>
}

let currentStandingCard = (standing: currentStanding) => {
  <div className="shadow  rounded-lg border p-4" id="currentStanding">
    <div className="ml-4 flex flex-col">
      <div className="font-semibold text-base"> {"Current Standing"->str} </div>
      <div className="flex flex-col justify-center items-center">
        {shieldIcon(standing.color)}
        <div
          style={ReactDOM.Style.make(~color=standing.color, ())}
          className={`font-medium text-base`}>
          {React.string(standing.name)}
        </div>
      </div>
    </div>
  </div>
}

let deleteIcon = (id: string, setArchive, archive, setState) => {
  <button
    ariaLabel={t("delete_note") ++ id}
    className="w-10 text-sm text-gray-600 hover:text-gray-900 cursor-pointer flex items-center justify-center rounded hover:bg-gray-50 hover:text-red-500 focus:outline-none focus:bg-gray-50 focus:text-red-500 focus:ring-2 focus:ring-inset focus:ring-red-500 "
    disabled=archive
    title={t("delete_note") ++ id}
    onClick={archiveStanding(id, setArchive, setState)}>
    <PfIcon className="if i-trash-regular if-fw text-2xl" />
  </button>
}

let standingLogItem = (log: userStanding, setArchive, archive, setState) => {
  <div className="bg-white rounded-lg p-4 mb-4 shadow-md flex items-center">
    {shieldIcon(log.standingColor)}
    <div className="ml-4 flex-grow">
      <div
        style={ReactDOM.Style.make(~color=log.standingColor, ())}
        className={`font-medium text-base`}>
        {React.string(log.standingName)}
      </div>
      <div className="text-gray-500">
        <PfIcon className="if i-calendar-regular if-fw" />
        {log.createdAt->DateFns.format("MMMM d yyyy")->str}
        {"•"->str}
        {log.createdAt->DateFns.format("h:mm a")->str}
        <PfIcon className="if i-teacher-coach-regular if-fw" />
        {log.creatorName->str}
      </div>
      <div className="mt-1"> {log.reason->str} </div>
    </div>
    <div className="ml-4"> {deleteIcon(log.id, setArchive, archive, setState)} </div>
  </div>
}

let standingLogs = (userStandings: userStandings, setArchive, archive, setState) => {
  <div className="mt-5">
    <h2 className="text-2xl font-semibold mb-4"> {"Standing Log"->str} </h2>
    <div>
      {switch userStandings->Js.Array2.length {
      | 0 => <div className="text-gray-600"> {"No standing log entries"->str} </div>
      | 1 => standingLogItem(Js.Array2.unsafe_get(userStandings, 0), setArchive, archive, setState)
      | _ =>
        userStandings
        ->Js.Array2.map(log => standingLogItem(log, setArchive, archive, setState))
        ->React.array
      }}
    </div>
  </div>
}

let changeStandingButtonDisabled = (reason, standing) => reason == "" || standing == "0"

let editor = (
  standings,
  setReason,
  reason,
  setState,
  studentId,
  setStanding,
  standing,
  currentStanding,
) => {
  <div>
    <h2 className="text-2xl font-semibold mb-4"> {"change standing"->str} </h2>
    <p className="mb-4"> {"You can change users standing to any standing."->str} </p>
    <div className="flex space-x-2">
      <div className="relative">
        <select
          className="block appearance-none w-full bg-gray-200 border border-gray-200 text-gray-700 py-2 px-4 pr-8 rounded leading-tight focus:outline-none focus:bg-white focus:border-gray-500"
          disabled=true>
          <option> {currentStanding.name->str} </option>
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
          ariaLabel="Select Standing"
          className="block appearance-none w-full bg-white border text-sm border-gray-300 rounded-s hover:border-gray-500 px-4 py-3 pe-8 rounded-e-none leading-tight focus:outline-none focus:ring-2 focus:ring-inset focus:ring-focusColor-500"
          id="change-standing"
          onChange={event => {
            let value = ReactEvent.Form.target(event)["value"]
            setStanding(_ => value)
          }}
          value=standing>
          <option key="0" value="0"> {"Select Standing"->str} </option>
          {standings
          ->Js.Array2.map(standing => {
            <option key=standing.id value=standing.id> {standing.name->str} </option>
          })
          ->React.array}
        </select>
        <div
          className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700">
          <PfIcon className="if i-chevron-down-regular if-fw" />
        </div>
      </div>
    </div>
    <div className="mt-4">
      <label className="block text-sm font-medium text-gray-700 mb-2">
        {"Reason for altering standing:"->str}
      </label>
      <div>
        <MarkdownEditor
          textareaId="reason-for-altering-standing"
          onChange={value => setReason(_ => value)}
          maxLength=200
          value=reason
          profile=Markdown.Permissive
          placeholder={"Eg. Plagiarism in assignment name, Misbehave in community..."}
        />
      </div>
    </div>
    <div>
      <button
        className="mt-4 btn btn-primary btn-sm"
        disabled={changeStandingButtonDisabled(reason, standing)}
        onClick={_e => {
          createUserStanding(studentId, reason, standing, setState, setReason, setStanding)
        }}>
        {"Change Standing"->str}
      </button>
    </div>
  </div>
}

@react.component
let make = (~studentId) => {
  let (state, setState) = React.useState(() => Unloaded)
  let (archive, setArchive) = React.useState(() => false)
  let (reason, setReason) = React.useState(() => "")
  let (standing, setStanding) = React.useState(() => "0")

  let courseContext = React.useContext(SchoolRouter__CourseContext.context)

  React.useEffect1(() => {
    loadData(studentId, setState, courseContext.setCourseId)
    None
  }, [studentId])

  switch state {
  | Unloaded
  | Loading =>
    SkeletonLoading.coursePage()
  | Loaded(baseData) =>
    <div>
      <School__PageHeader
        exitUrl={`/school/courses/${baseData.courseId}/students`}
        title={`${t("edit")} ${baseData.student.name}`}
        description={baseData.student.email}
        links={pageLinks(studentId)}
      />
      <div className="max-w-4xl 2xl:max-w-5xl mx-auto px-4 mt-5">
        {currentStandingCard(baseData.currentStanding)}
        {standingLogs(baseData.userStandings, setArchive, archive, setState)}
        {editor(
          baseData.standings,
          setReason,
          reason,
          setState,
          studentId,
          setStanding,
          standing,
          baseData.currentStanding,
        )}
      </div>
    </div>
  | Errored => <ErrorState />
  }
}

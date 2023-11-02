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

type standings = array<standing>

type baseData = {
  student: student,
  userStandings: userStandings,
  courseId: string,
  standings: standings,
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

let loadData = (studentId, setState, setCourseId) => {
  setState(_ => Loading)
  StudentStandingDataQuery.fetch(~notifyOnNotFound=false, {studentId: studentId})
  |> Js.Promise.then_((response: StudentStandingDataQuery.t) => {
    setState(_ => Loaded({
      student: {
        name: response.student.user.name,
        email: response.student.user.email,
      },
      userStandings: response.userStandings->Js.Array2.map(
        userStanding => {
          id: userStanding.id,
          standingName: userStanding.standingName,
          standingColor: userStanding.standingColor,
          createdAt: userStanding.createdAt->DateFns.decodeISO,
          creatorName: userStanding.creatorName,
          reason: userStanding.reason,
        },
      ),
      courseId: response.student.course.id,
      standings: response.standings->Js.Array2.map(
        standing => {
          id: standing.id,
          name: standing.name,
          color: standing.color,
          description: standing.description,
        },
      ),
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
          | Loaded(data) =>
            Loaded({
              ...data,
              userStandings: data.userStandings->Js.Array2.filter(standing => standing.id !== id),
            })
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

let defaultStanding = (standings: standings) => {
  let standing = Js.Array2.unsafe_get(standings, 0)
  <div className="shadow  rounded-lg border p-4">
    <div className="ml-4">
      {shieldIcon(standing.color)}
      <div className="font-medium text-base"> {"Current Standing"->str} </div>
      <div className="text-gray-600"> {standing.name->str} </div>
    </div>
  </div>
}

let currentStanding = (userStandings: userStandings, standings: standings) => {
  Js.Array2.length(userStandings) == 0
    ? defaultStanding(standings)
    : {
        let standing = Js.Array2.unsafe_get(userStandings, 0)
        <div className="shadow  rounded-lg border p-4">
          <div className="ml-4">
            {shieldIcon(standing.standingColor)}
            <div className="font-bold text-lg"> {"Current Standing"->str} </div>
            <div className="text-gray-600"> {standing.standingName->str} </div>
          </div>
        </div>
      }
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

let standingLog = (userStandings: userStandings, setArchive, archive, setState) => {
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

@react.component
let make = (~studentId) => {
  let (state, setState) = React.useState(() => Unloaded)
  let (archive, setArchive) = React.useState(() => false)

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
        {currentStanding(baseData.userStandings, baseData.standings)}
        {standingLog(baseData.userStandings, setArchive, archive, setState)}
      </div>
    </div>
  | Errored => <ErrorState />
  }
}

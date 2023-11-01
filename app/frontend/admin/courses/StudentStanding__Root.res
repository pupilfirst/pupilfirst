let t = I18n.t(~scope="components.StudentDetails__Root")
let ts = I18n.ts

type student = {
  name: string,
  email: string,
}

type userStanding = {
  id: string,
  standingName: string,
  createdAt: Js.Date.t,
  creatorName: string,
  reason: string,
}

type userStandings = array<userStanding>

type baseData = {
  student: student,
  userStandings: userStandings,
  courseId: string,
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
  query studentStandingDataQuery($studentId: ID!, $userId: ID!) {
    student(studentId: $studentId) {
      user {
        name
        email
      }
      course {
        id
      }
    }
    userStandings(userId: $userId) {
      id
      standingName
      createdAt
      creatorName
      reason
    }
  }
`)

let loadData = (studentId, userId, setState, setCourseId) => {
  setState(_ => Loading)
  StudentStandingDataQuery.fetch(~notifyOnNotFound=false, {studentId, userId})
  |> Js.Promise.then_((response: StudentStandingDataQuery.t) => {
    setState(_ => Loaded({
      student: {
        name: response.student.user.name,
        email: response.student.user.email,
      },
      userStandings: response.userStandings->Js.Array2.map(
        standing => {
          id: standing.id,
          standingName: standing.standingName,
          createdAt: standing.createdAt->DateFns.decodeISO,
          creatorName: standing.creatorName,
          reason: standing.reason,
        },
      ),
      courseId: response.student.course.id,
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

@react.component
let make = (~studentId, ~userId) => {
  let (state, setState) = React.useState(() => Unloaded)
  let courseContext = React.useContext(SchoolRouter__CourseContext.context)

  React.useEffect1(() => {
    loadData(studentId, userId, setState, courseContext.setCourseId)
    None
  }, [studentId])

  <div>
    <School__PageHeader
      exitUrl={`/school/courses/3/students`}
      title={`${t("edit")} `}
      description={"test"}
      links={pageLinks(studentId)}
    />
  </div>
}

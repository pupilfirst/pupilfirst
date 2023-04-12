open CourseCoaches__Types

let str = React.string

let tr = I18n.t(~scope="components.CourseCoaches__InfoFormStudent")
let ts = I18n.t(~scope="shared")

let deleteIconClasses = deleting => deleting ? "fas fa-spinner fa-pulse" : "far fa-trash-alt"

module DeleteCoachStudentEnrollmentQuery = %graphql(`
  mutation($studentId: ID!, $coachId: ID!) {
    deleteCoachStudentEnrollment(studentId: $studentId, coachId: $coachId) {
      success
    }
  }
`)

let deleteStudentEnrollment = (student, coach, setDeleting, removeStudentEnrollmentCB, event) => {
  event |> ReactEvent.Mouse.preventDefault

  WindowUtils.confirm(
    tr("remove_pre_confirm") ++ ((student |> Student.name) ++ tr("remove_post_confirm")),
    () => {
      setDeleting(_ => true)
      let variables = DeleteCoachStudentEnrollmentQuery.makeVariables(
        ~studentId=Student.id(student),
        ~coachId=CourseCoach.id(coach),
        (),
      )
      DeleteCoachStudentEnrollmentQuery.fetch(variables)
      |> Js.Promise.then_((response: DeleteCoachStudentEnrollmentQuery.t) => {
        if response.deleteCoachStudentEnrollment.success {
          removeStudentEnrollmentCB(Student.id(student))
        } else {
          setDeleting(_ => false)
        }
        response |> Js.Promise.resolve
      })
      |> ignore
    },
  )
}

@react.component
let make = (~student, ~coach, ~removeStudentEnrollmentCB) => {
  let (deleting, setDeleting) = React.useState(() => false)
  <div
    ariaLabel={ts("student") ++ " " ++ student->Student.name}
    className="flex items-center justify-between bg-gray-50 text-xs text-gray-900 border rounded ps-3 mt-2"
    key={student->Student.id}>
    <div className="flex flex-1 justify-between items-center">
      <div className="font-semibold w-1/2"> {student->Student.name->str} </div>
    </div>
    <div className="w-10 text-center flex-shrink-0 hover:text-gray-900 hover:bg-gray-50">
      <button
        title={ts("delete") ++ " " ++ Student.name(student)}
        onClick={deleteStudentEnrollment(student, coach, setDeleting, removeStudentEnrollmentCB)}
        className="p-3">
        <FaIcon classes={deleteIconClasses(deleting)} />
      </button>
    </div>
  </div>
}

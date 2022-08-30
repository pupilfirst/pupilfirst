exception UnsafeFindFailed(string)

type courseId = string
type id = string

type t =
  | Student__Curriculum(courseId)
  | Student__Report(courseId)
  | Student__Review(courseId)
  | Student__Students(courseId)
  | Student__Leaderboard(courseId)
  | Student__SubmissionShow(id)

let showSideNav = t => {
  switch t {
  | Student__Review(_id)
  | Student__Curriculum(_id)
  | Student__Students(_id)
  | Student__Report(_id)
  | Student__Leaderboard(_id) => true
  | Student__SubmissionShow(_id) => false
  }
}

let courseId = t =>
  switch t {
  | Student__Review(courseId)
  | Student__Curriculum(courseId)
  | Student__Students(courseId)
  | Student__Report(courseId)
  | Student__Leaderboard(courseId) =>
    Some(courseId)
  | Student__SubmissionShow(_id) => None
  }

let path = t => {
  switch t {
  | Student__Curriculum(courseId) => `/courses/${courseId}/curriculum`
  | Student__Report(courseId) => `/courses/${courseId}/report`
  | Student__Students(courseId) => `/courses/${courseId}/students`
  | Student__Review(courseId) => `/courses/${courseId}/review`
  | Student__Leaderboard(courseId) => `/courses/${courseId}/leaderboard`
  | Student__SubmissionShow(submissionId) => `/submissions/${submissionId}/review`
  }
}

let activeLinks = currentCourse => {
  let id = AppRouter__Course.id(currentCourse)

  let defaultLinks = [Student__Curriculum(id)]
  let linksForStudents = AppRouter__Course.isStudent(currentCourse)
    ? Js.Array.concat([Student__Report(id)], defaultLinks)
    : defaultLinks

  AppRouter__Course.canReview(currentCourse)
    ? Js.Array.concat([Student__Review(id), Student__Students(id)], linksForStudents)
    : linksForStudents
}

let changeId = (t, id) => {
  switch t {
  | Student__Curriculum(_id) => Student__Curriculum(id)
  | Student__Report(_id) => Student__Report(id)
  | Student__Students(_id) => Student__Students(id)
  | Student__Review(_id) => Student__Review(id)
  | Student__Leaderboard(_id) => Student__Leaderboard(id)
  | Student__SubmissionShow(_id) => Student__SubmissionShow(id)
  }
}

let canAccessPage = (t, course) => {
  Belt.Option.isSome(
    Js.Array.find(l => l == changeId(t, AppRouter__Course.id(course)), activeLinks(course)),
  )
}

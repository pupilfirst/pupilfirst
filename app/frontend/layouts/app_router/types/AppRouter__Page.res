exception UnsafeFindFailed(string)

type courseId = string
type id = string

type coursePages =
  | Curriculum
  | Report
  | Review
  | Students
  | Leaderboard
  | Calendar

type t =
  | SelectedCourse(courseId, coursePages)
  | Student__SubmissionShow(id)
  | Student__StudentsReport(id)

let showSideNav = t => {
  switch t {
  | SelectedCourse(_id, _pages) => true
  | Student__StudentsReport(_id)
  | Student__SubmissionShow(_id) => false
  }
}

let coursePath = (id, page) => {
  `/courses/${id}/` ++
  switch page {
  | Curriculum => `curriculum`
  | Report => `report`
  | Review => `review`
  | Students => `students`
  | Leaderboard => `leaderboard`
  | Calendar => `calendar`
  }
}
let path = t => {
  switch t {
  | SelectedCourse(id, page) => coursePath(id, page)
  | Student__SubmissionShow(submissionId) => `/submissions/${submissionId}/review`
  | Student__StudentsReport(studentId) => `/students/${studentId}/report`
  }
}

let activeLinks = currentCourse => {
  let defaultLinks = [Curriculum, Calendar]
  let linksForStudents = AppRouter__Course.isStudent(currentCourse)
    ? Js.Array.concat([Report], defaultLinks)
    : defaultLinks

  AppRouter__Course.canReview(currentCourse)
    ? Js.Array.concat([Review, Students], linksForStudents)
    : linksForStudents
}

let isSPA = t => {
  switch t {
  | SelectedCourse(_id, l) =>
    switch l {
    | Curriculum
    | Report
    | Calendar
    | Students
    | Leaderboard => false
    | Review => true
    }
  | Student__SubmissionShow(_)
  | Student__StudentsReport(_) => true
  }
}

let useSPA = (selectedPage, page) => {
  isSPA(selectedPage) && isSPA(page)
}

let isSelectedCoursePage = (t, coursePage) => {
  switch t {
  | SelectedCourse(_, page) => page == coursePage
  | Student__StudentsReport(_)
  | Student__SubmissionShow(_) => false
  }
}

let canAccessPage = (coursePage, course) => {
  Belt.Option.isSome(activeLinks(course)->Js.Array2.find(l => l == coursePage))
}

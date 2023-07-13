exception UnsafeFindFailed(string)

let tr = I18n.t(~scope="components.SchoolRouter__Page")

type courseId = string
type id = string

type coursePages =
  | Students
  | CourseCoaches
  | Curriculum
  | EvaluationCriteria
  | CourseExports
  | Authors
  | Certificates
  | Applicants
  | Teams
  | Cohorts
  | Calendars
  | Assignments

type settingsPages =
  | Customization
  | Admins

type t =
  | SchoolCoaches
  | Settings(settingsPages)
  | Courses
  | SelectedCourse(coursePages)
  | Communities

let shrunk = t => {
  switch t {
  | SchoolCoaches
  | Courses
  | Communities => false
  | Settings(_settingsPages) => true
  | SelectedCourse(_coursePages) => true
  }
}

let isSPA = t => {
  switch t {
  | SchoolCoaches
  | Communities => false
  | Settings(_settingsPages) => false
  | SelectedCourse(coursePages) =>
    switch coursePages {
    | Cohorts
    | Students
    | Teams => true
    | CourseCoaches
    | Curriculum
    | EvaluationCriteria
    | CourseExports
    | Authors
    | Certificates
    | Calendars
    | Applicants
    | Assignments => false
    }

  | Courses => true
  }
}

let useSPA = (selectedPage, page) => {
  isSPA(selectedPage) && isSPA(page)
}

let coursePath = (coursePage, courseId) => {
  switch coursePage {
  | Students => `/school/courses/${courseId}/students?status=Active`
  | CourseCoaches => `/school/courses/${courseId}/coaches`
  | Curriculum => `/school/courses/${courseId}/curriculum`
  | EvaluationCriteria => `/school/courses/${courseId}/evaluation_criteria`
  | CourseExports => `/school/courses/${courseId}/exports`
  | Authors => `/school/courses/${courseId}/authors`
  | Certificates => `/school/courses/${courseId}/certificates`
  | Applicants => `/school/courses/${courseId}/applicants`
  | Teams => `/school/courses/${courseId}/teams?status=Active`
  | Cohorts => `/school/courses/${courseId}/cohorts?status=Active`
  | Calendars => `/school/courses/${courseId}/calendar_events`
  | Assignments => `/school/courses/${courseId}/assignments`
  }
}

let path = (~courseId=?, t) => {
  switch t {
  | SchoolCoaches => "/school/coaches"
  | Settings(settingsPages) =>
    switch settingsPages {
    | Customization => "/school/customize"
    | Admins => "/school/admins"
    }
  | Courses => "/school/courses"
  | SelectedCourse(coursePage) =>
    courseId->Belt.Option.mapWithDefault("#", id => coursePath(coursePage, id))
  | Communities => "/school/communities"
  }
}

let primaryNavName = t =>
  switch t {
  | SchoolCoaches => tr("nav.main.coaches")
  | Settings(_) => tr("nav.main.settings")
  | Courses => tr("nav.main.courses")
  | Communities => tr("nav.main.communities")
  | SelectedCourse(_) => "Invalid"
  }

let secondaryNavName = t =>
  switch t {
  | Settings(settingsPages) =>
    switch settingsPages {
    | Customization => tr("nav.settings.customization")
    | Admins => tr("nav.settings.admins")
    }
  | SelectedCourse(coursePages) =>
    switch coursePages {
    | Students => tr("nav.course.students")
    | CourseCoaches => tr("nav.course.coaches")
    | Curriculum => tr("nav.course.curriculum")
    | EvaluationCriteria => tr("nav.course.evaluation_criteria")
    | CourseExports => tr("nav.course.exports")
    | Authors => tr("nav.course.authors")
    | Certificates => tr("nav.course.certificates")
    | Applicants => tr("nav.course.applicants")
    | Teams => tr("nav.course.teams")
    | Cohorts => tr("nav.course.cohorts")
    | Calendars => tr("nav.course.calendar")
    | Assignments => tr("nav.course.assignments")
    }
  | Courses
  | Communities
  | SchoolCoaches => "Invalid"
  }

let icon = t => {
  switch t {
  | SchoolCoaches => "users"
  | Settings(_settingsPages) => "cog"
  | Courses => "journal-text"
  | SelectedCourse(_coursePages) => "fas fa-book"
  | Communities => "comment-alt"
  }
}

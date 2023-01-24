exception UnsafeFindFailed(string)

let ct = I18n.t(~scope="components.SchoolAdminNavbar__Root.course_nav")
let tt = I18n.t(~scope="components.SchoolAdminNavbar__Root.navbar")

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
    | Applicants => false
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

let name = t => {
  switch t {
  | SchoolCoaches => tt("coaches")
  | Settings(settingsPages) =>
    switch settingsPages {
    | Customization => tt("settings")
    | Admins => tt("admins")
    }
  | Courses => tt("courses")
  | SelectedCourse(coursePages) =>
    switch coursePages {
    | Students => ct("students")
    | CourseCoaches => ct("coaches")
    | Curriculum => ct("curriculum")
    | EvaluationCriteria => ct("evaluation_criteria")
    | CourseExports => ct("exports")
    | Authors => ct("authors")
    | Certificates => ct("certificates")
    | Applicants => ct("applicants")
    | Teams => I18n.t("components.TeamsIndex__Root.teams")
    | Cohorts => I18n.t("components.CohortsIndex__Root.cohorts")
    | Calendars => ct("calendar")
    }
  | Communities => tt("communities")
  }
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

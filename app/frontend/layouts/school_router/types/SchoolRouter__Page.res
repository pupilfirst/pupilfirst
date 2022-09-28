exception UnsafeFindFailed(string)

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
  | SchoolCoaches => "Coaches"
  | Settings(settingsPages) =>
    switch settingsPages {
    | Customization => "Customization"
    | Admins => "Admins"
    }
  | Courses => "Courses"
  | SelectedCourse(coursePages) =>
    switch coursePages {
    | Students => "Students"
    | CourseCoaches => "Coaches"
    | Curriculum => "Curriculum"
    | EvaluationCriteria => "Evaluation Criteria"
    | CourseExports => "Exports"
    | Authors => "Authors"
    | Certificates => "Certificates"
    | Applicants => "Applicants"
    | Teams => "Teams"
    | Cohorts => "Cohorts"
    }
  | Communities => "Communities"
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

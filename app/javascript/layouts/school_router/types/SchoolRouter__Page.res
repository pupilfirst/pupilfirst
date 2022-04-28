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

type settingsPages =
  | Customization
  | Admins

type t =
  | Overview
  | SchoolCoaches
  | Settings(settingsPages)
  | Courses
  | SelectedCourse(courseId, coursePages)
  | Communities

let shrunk = t => {
  switch t {
  | Overview
  | SchoolCoaches
  | Courses
  | Communities => false
  | Settings(_settingsPages) => true
  | SelectedCourse(_courseId, _coursePages) => true
  }
}

let isSPA = t => {
  switch t {
  | Overview
  | SchoolCoaches
  | Communities => false
  | Settings(_settingsPages) => false
  | SelectedCourse(_courseId, _coursePages) => false
  | Courses => true
  }
}

let useSPA = (selectedPage, page) => {
  isSPA(selectedPage) && isSPA(page)
}

let path = t => {
  switch t {
  | Overview => "/school"
  | SchoolCoaches => "/school/coaches"
  | Settings(settingsPages) =>
    switch settingsPages {
    | Customization => "/school/customize"
    | Admins => "/school/admins"
    }
  | Courses => "/school/courses"
  | SelectedCourse(courseId, coursePages) =>
    switch coursePages {
    | Students => `/school/courses/${courseId}/students`
    | CourseCoaches => `/school/courses/${courseId}/coaches`
    | Curriculum => `/school/courses/${courseId}/curriculum`
    | EvaluationCriteria => `/school/courses/${courseId}/evaluation_criteria`
    | CourseExports => `/school/courses/${courseId}/exports`
    | Authors => `/school/courses/${courseId}/authors`
    | Certificates => `/school/courses/${courseId}/certificates`
    | Applicants => `/school/courses/${courseId}/applicants`
    }
  | Communities => "/school/communities"
  }
}

let name = t => {
  switch t {
  | Overview => "Overview"
  | SchoolCoaches => "Coaches"
  | Settings(settingsPages) =>
    switch settingsPages {
    | Customization => "Customization"
    | Admins => "Admins"
    }
  | Courses => "Courses"
  | SelectedCourse(_courseId, coursePages) =>
    switch coursePages {
    | Students => "Students"
    | CourseCoaches => "Coaches"
    | Curriculum => "Curriculum"
    | EvaluationCriteria => "Evaluation Criteria"
    | CourseExports => "Exports"
    | Authors => "Authors"
    | Certificates => "Certificates"
    | Applicants => "Applicants"
    }
  | Communities => "Communities"
  }
}

let icon = t => {
  switch t {
  | Overview => "fas fa-eye"
  | SchoolCoaches => "fas fa-chalkboard-teacher"
  | Settings(_settingsPages) => "fas fa-cog"
  | Courses => "fas fa-book"
  | SelectedCourse(_courseId, _coursePages) => "fas fa-book"
  | Communities => "fas fa-users"
  }
}

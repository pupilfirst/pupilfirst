module Types
  class CourseResourceType < Types::BaseEnum
    value 'Level', 'Levels in the course'
    value 'Cohort', 'Cohorts in the course'
    value 'StudentTag', 'Student tags in the course'
    value 'UserTag', 'User tags in the course'
    value 'Coach', 'Coaches in the course'
  end
end

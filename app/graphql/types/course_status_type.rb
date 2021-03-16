module Types
  class CourseStatusType < Types::BaseEnum
    value 'Active', 'List of active courses'
    value 'Ended', 'List of ended courses'
    value 'Archived', 'List of archived courses'
  end
end

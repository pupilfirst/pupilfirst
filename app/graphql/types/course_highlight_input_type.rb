module Types
  class CourseHighlightInputType < Types::BaseInputObject
    argument :icon, String, required: true
    argument :title, String, required: true
    argument :description, String, required: true
  end
end

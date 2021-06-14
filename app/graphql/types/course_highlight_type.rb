module Types
  class CourseHighlightType < Types::BaseObject
    field :icon, String, null: false
    field :title, String, null: false
    field :description, String, null: false
  end
end

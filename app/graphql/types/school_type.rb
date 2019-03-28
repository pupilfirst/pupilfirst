module Types
  class SchoolType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :courses, [Types::CourseType], null: false
  end
end

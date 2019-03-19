module Types
  class CourseType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
  end
end

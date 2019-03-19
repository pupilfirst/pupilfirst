module Types
  class CourseType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :ends_at, GraphQL::Types::ISO8601DateTime, null: true
    field :max_grade, Integer, null: false
    field :pass_grade, Integer, null: false
  end
end

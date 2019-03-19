module Types
  class QueryType < Types::BaseObject
    field :courses, [Types::CourseType], null: false

    def courses
      context[:current_school].courses
    end
  end
end

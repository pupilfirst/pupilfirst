module Types
  class QueryType < Types::BaseObject
    field :courses, [Types::CourseType], null: false

    def courses
      CoursesResolver.new(context).collection
    end
  end
end

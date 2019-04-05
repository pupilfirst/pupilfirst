module Types
  class QueryType < Types::BaseObject
    field :courses, [Types::CourseType], null: false
    field :community, [Types::CommunityType], null: false

    def courses
      context[:current_school].courses
    end

    def community
      context[:current_school].community
    end
  end
end

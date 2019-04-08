module Types
  class QueryType < Types::BaseObject
    field :courses, [Types::CourseType], null: false
    # field :community, [Types::CommunityType], null: false

    def courses
      CoursesResolver.new(context).collection
    end

    # def community(id:)
    #   CommunitiesResolver.new(context).member(id)
    # end
  end
end

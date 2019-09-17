module Types
  class QueryType < Types::BaseObject
    field :courses, [Types::CourseType], null: false
    field :content_blocks, [Types::ContentBlockType], null: false do
      argument :target_id, ID, required: true
      argument :version_on, Types::DateType, required: false
    end

    field :versions, [Types::DateType], null: false do
      argument :target_id, ID, required: true
    end

    def courses
      CoursesResolver.new(context).collection
    end

    def content_blocks(args)
      ContentBlockResolver.new(context).collection(args[:target_id], args[:version_on])
    end

    def versions(args)
      ContentVersionResolver.new(context).collection(args[:target_id])
    end
  end
end

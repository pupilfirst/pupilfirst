module Types
  class QueryType < Types::BaseObject
    field :courses, [Types::CourseType], null: false
    field :content_blocks, [Types::ContentBlockType], null: false do
      argument :target_id, ID, required: true
      argument :version_id, ID, required: false
    end

    def courses
      CoursesResolver.new(context).collection
    end

    def content_blocks(args)
      ContentBlockResolver.new(context).collection(args[:target_id], args[:version_id])
    end
  end
end

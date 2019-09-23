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

    field :reviewed_submissions, Types::ReviewedSubmissionType.connection_type, null: false do
      argument :course_id, ID, required: true
      argument :level_id, ID, required: false
    end

    field :submission_details, [Types::SubmissionDetailsType], null: false do
      argument :submission_id, ID, required: true
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

    def reviewed_submissions(args)
      ReviewedSubmissionsResolver.new(context).collection(args[:course_id], args[:level_id])
    end

    def submission_details(args)
      SubmissionDetailsResolver.new(context).collection(args[:submission_id])
    end
  end
end

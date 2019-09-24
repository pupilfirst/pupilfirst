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

    field :submission_details, Types::SubmissionDetailsType, null: false do
      argument :submission_id, ID, required: true
    end

    def courses
      resolver = CoursesResolver.new(context)
      resolver.authorize
      resolver.courses
    end

    def content_blocks(args)
      resolver = ContentBlockResolver.new(context, args)
      resolver.authorize
      resolver.content_blocks
    end

    def versions(args)
      resolver = ContentVersionResolver.new(context, args)
      resolver.authorize
      resolver.versions
    end

    def reviewed_submissions(args)
      resolver = ReviewedSubmissionsResolver.new(context, args)
      resolver.authorize
      resolver.reviewed_submissions
    end

    def submission_details(args)
      resolver = SubmissionDetailsResolver.new(context, args)
      resolver.authorize
      resolver.submission_details
    end
  end
end

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

    field :teams, Types::TeamType.connection_type, null: false do
      argument :course_id, ID, required: true
      argument :level_id, ID, required: false
      argument :search, String, required: false
    end

    field :student_details, Types::StudentDetailsType, null: false do
      argument :student_id, ID, required: true
    end

    field :student_submissions, Types::StudentSubmissionType.connection_type, null: false do
      argument :student_id, ID, required: true
    end

    field :evaluation_criteria, [Types::EvaluationCriterionType], null: false do
      argument :course_id, ID, required: true
    end

    def courses
      resolver = CoursesResolver.new(context)
      resolver.courses
    end

    def teams(args)
      resolver = TeamsResolver.new(context, args)
      resolver.teams
    end

    def content_blocks(args)
      resolver = ContentBlockResolver.new(context, args)
      resolver.content_blocks
    end

    def versions(args)
      resolver = ContentVersionResolver.new(context, args)
      resolver.versions
    end

    def reviewed_submissions(args)
      resolver = ReviewedSubmissionsResolver.new(context, args)
      resolver.reviewed_submissions
    end

    def submission_details(args)
      resolver = SubmissionDetailsResolver.new(context, args)
      resolver.submission_details
    end

    def student_details(args)
      resolver = StudentDetailsResolver.new(context, args)
      resolver.student_details
    end

    def student_submissions(args)
      resolver = StudentSubmissionsResolver.new(context, args)
      resolver.student_submissions
    end

    def evaluation_criteria(args)
      resolver = EvaluationCriteriaResolver.new(context, args)
      resolver.evaluation_criteria
    end
  end
end

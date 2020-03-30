module Types
  class QueryType < Types::BaseObject
    field :courses, [Types::CourseType], null: false

    field :content_blocks, [Types::ContentBlockType], null: false do
      argument :target_id, ID, required: true
      argument :target_version_id, ID, required: false
    end

    field :versions, [Types::TargetVersionType], null: false do
      argument :target_id, ID, required: true
    end

    field :reviewed_submissions, Types::ReviewedSubmissionType.connection_type, null: false do
      argument :course_id, ID, required: true
      argument :level_id, ID, required: false
      argument :coach_id, ID, required: false
      argument :sort_direction, Types::SortDirectionType, required: true
    end

    field :submissions, Types::SubmissionType.connection_type, null: false do
      argument :course_id, ID, required: true
      argument :status, Types::SubmissionStatusType, required: true
      argument :level_id, ID, required: false
      argument :coach_id, ID, required: false
    end

    field :submission_details, Types::SubmissionDetailsType, null: false do
      argument :submission_id, ID, required: true
    end

    field :teams, Types::TeamType.connection_type, null: false do
      argument :course_id, ID, required: true
      argument :level_id, ID, required: false
      argument :coach_id, ID, required: false
      argument :search, String, required: false
    end

    field :student_details, Types::StudentDetailsType, null: false do
      argument :student_id, ID, required: true
    end

    field :student_submissions, Types::StudentSubmissionType.connection_type, null: false do
      argument :student_id, ID, required: true
    end

    field :course_teams, Types::CourseTeamType.connection_type, null: false do
      argument :course_id, ID, required: true
      argument :level_id, ID, required: false
      argument :search, String, required: false
      argument :tags, [String], required: false
      argument :sort_by, String, required: true
    end

    field :evaluation_criteria, [Types::EvaluationCriterionType], null: false do
      argument :course_id, ID, required: true
    end

    field :target_details, Types::TargetDetailsType, null: false do
      argument :target_id, ID, required: true
    end

    field :coach_stats, Types::CoachStatsType, null: false do
      argument :coach_id, ID, required: true
      argument :course_id, ID, required: true
    end

    field :similar_questions, [Types::QuestionType], null: false do
      argument :community_id, ID, required: true
      argument :title, String, required: true
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
      resolver = TargetVersionResolver.new(context, args)
      resolver.versions
    end

    def submissions(args)
      resolver = SubmissionsResolver.new(context, args)
      resolver.submissions
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

    def course_teams(args)
      resolver = CourseTeamsResolver.new(context, args)
      resolver.course_teams
    end

    def evaluation_criteria(args)
      resolver = EvaluationCriteriaResolver.new(context, args)
      resolver.evaluation_criteria
    end

    def target_details(args)
      resolver = TargetDetailsResolver.new(context, args)
      resolver.target_details
    end

    def coach_stats(args)
      resolver = CoachStatsResolver.new(context, args)
      resolver.coach_stats
    end

    def similar_questions(args)
      resolver = SimilarQuestionsResolver.new(context, args)
      resolver.similar_questions
    end
  end
end

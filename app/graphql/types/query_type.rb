module Types
  class QueryType < Types::BaseObject
    class << self
      attr_accessor :resolved_fields

      def resolved_field(*args, &block)
        self.resolved_fields ||= []
        self.resolved_fields << args[0]

        field(*args, &block)
      end
    end

    def resolved_fields
      self.class.resolved_fields
    end

    def respond_to_missing?(name, *args)
      resolved_fields.include?(name.to_sym) || super
    end

    def method_missing(name, *args)
      if resolved_fields.include?(name)
        resolver = (name.to_s + '_resolver').camelcase.constantize.new(context, args[0] || {})
        resolver.public_send(name)
      else
        super
      end
    end

    resolved_field :courses, [Types::CourseType], null: false

    resolved_field :content_blocks, [Types::ContentBlockType], null: false do
      argument :target_id, ID, required: true
      argument :target_version_id, ID, required: false
    end

    resolved_field :target_versions, [Types::TargetVersionType], null: false do
      argument :target_id, ID, required: true
    end

    resolved_field :submissions, Types::SubmissionType.connection_type, null: false do
      argument :course_id, ID, required: true
      argument :status, Types::SubmissionStatusType, required: true
      argument :sort_direction, Types::SortDirectionType, required: true
      argument :sort_criterion, Types::SubmissionSortCriterionType, required: true
      argument :level_id, ID, required: false
      argument :coach_id, ID, required: false
    end

    resolved_field :submission_details, Types::SubmissionDetailsType, null: false do
      argument :submission_id, ID, required: true
    end

    resolved_field :teams, Types::TeamType.connection_type, null: false do
      argument :course_id, ID, required: true
      argument :coach_notes, Types::CoachNoteFilterType, required: true
      argument :tags, [String], required: true
      argument :level_id, ID, required: false
      argument :coach_id, ID, required: false
      argument :search, String, required: false
    end

    resolved_field :student_details, Types::StudentDetailsType, null: false do
      argument :student_id, ID, required: true
    end

    resolved_field :student_submissions, Types::StudentSubmissionType.connection_type, null: false do
      argument :student_id, ID, required: true
      argument :level_id, ID, required: false
      argument :status, Types::SubmissionReviewStatusType, required: false
      argument :sort_direction, Types::SortDirectionType, required: true
    end

    resolved_field :course_teams, Types::CourseTeamType.connection_type, null: false do
      argument :course_id, ID, required: true
      argument :level_id, ID, required: false
      argument :search, String, required: false
      argument :tags, [String], required: false
      argument :sort_by, String, required: true
      argument :sort_direction, Types::SortDirectionType, required: true
    end

    resolved_field :evaluation_criteria, [Types::EvaluationCriterionType], null: false do
      argument :course_id, ID, required: true
    end

    resolved_field :target_details, Types::TargetDetailsType, null: false do
      argument :target_id, ID, required: true
    end

    resolved_field :coach_stats, Types::CoachStatsType, null: false do
      argument :coach_id, ID, required: true
      argument :course_id, ID, required: true
    end

    resolved_field :similar_topics, [Types::TopicType], null: false do
      argument :community_id, ID, required: true
      argument :title, String, required: true
    end

    resolved_field :coach_notes, [Types::CoachNoteType], null: false do
      argument :student_id, ID, required: true
    end

    resolved_field :has_archived_coach_notes, Boolean, null: false do
      argument :student_id, ID, required: true
    end

    resolved_field :student_distribution, [Types::DistributionInLevelType], null: false do
      argument :course_id, ID, required: true
      argument :coach_notes, Types::CoachNoteFilterType, required: true
      argument :tags, [String], required: true
      argument :coach_id, ID, required: false
    end

    resolved_field :topics, Types::TopicType.connection_type, null: false do
      argument :community_id, ID, required: true
      argument :resolution, Types::TopicResolutionFilterType, required: true
      argument :topic_category_id, ID, required: false
      argument :target_id, ID, required: false
      argument :search, String, required: false
      argument :sort_direction, Types::SortDirectionType, required: true
      argument :sort_criterion, Types::TopicSortCriterionType, required: true
    end

    resolved_field :notifications, Types::NotificationType.connection_type, null: false do
      argument :search, String, required: false
      argument :status, Types::NotificationStatusType, required: false
      argument :event, Types::NotificationEventType, required: false
    end
  end
end

module Types
  class QueryType < Types::BaseObject
    class << self
      attr_accessor :resolved_fields

      def resolved_field(*args, null: nil, &block)
        self.resolved_fields ||= []
        self.resolved_fields << args[0]

        field(*args, null: null, &block)
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
        resolver =
          (name.to_s + "_resolver").camelcase.constantize.new(
            context,
            args[0] || {}
          )
        resolver.public_send(name)
      else
        super
      end
    end

    resolved_field :courses, Types::CourseType.connection_type, null: false do
      argument :search, String, required: false
      argument :status, Types::CourseStatusType, required: false
      argument :id, ID, required: false
    end

    resolved_field :course, Types::CourseType, null: false do
      argument :id, ID, required: true
    end

    resolved_field :cohort, Types::CohortType, null: false do
      argument :id, ID, required: true
    end

    resolved_field :cohorts, Types::CohortType.connection_type, null: false do
      argument :course_id, ID, required: true
      argument :filter_string, String, required: false
    end

    resolved_field :content_blocks, [Types::ContentBlockType], null: false do
      argument :target_id, ID, required: true
      argument :target_version_id, ID, required: false
    end

    resolved_field :target_versions, [Types::TargetVersionType], null: false do
      argument :target_id, ID, required: true
    end

    resolved_field :submissions,
                   Types::SubmissionInfoType.connection_type,
                   null: false do
      argument :course_id, ID, required: true
      argument :status, Types::SubmissionStatusType, required: false
      argument :sort_direction, Types::SortDirectionType, required: true
      argument :sort_criterion,
               Types::SubmissionSortCriterionType,
               required: true
      argument :personal_coach_id, ID, required: false
      argument :assigned_coach_id, ID, required: false
      argument :reviewing_coach_id, ID, required: false
      argument :target_id, ID, required: false
      argument :search, String, required: false
      argument :include_inactive, Boolean, required: false
    end

    resolved_field :submission_details,
                   Types::SubmissionDetailsType,
                   null: false do
      argument :submission_id, ID, required: true
    end

    resolved_field :teams, Types::TeamType.connection_type, null: false do
      argument :course_id, ID, required: true
      argument :filter_string, String, required: false
    end

    resolved_field :team, Types::TeamType, null: false do
      argument :id, ID, required: true
    end

    resolved_field :student_details, Types::StudentDetailsType, null: false do
      argument :student_id, ID, required: true
    end

    resolved_field :student_submissions,
                   Types::StudentSubmissionType.connection_type,
                   null: false do
      argument :student_id, ID, required: true
      argument :status, Types::SubmissionReviewStatusType, required: false
      argument :sort_direction, Types::SortDirectionType, required: true
    end

    resolved_field :submission_report,
                   Types::SubmissionReportType,
                   null: false do
      argument :id, ID, required: true
    end

    resolved_field :course_students,
                   Types::StudentType.connection_type,
                   null: false do
      argument :course_id, ID, required: true
      argument :filter_string, String, required: false
    end

    resolved_field :student, Types::StudentType, null: false do
      argument :student_id, ID, required: true
    end

    resolved_field :evaluation_criteria,
                   [Types::EvaluationCriterionType],
                   null: false do
      argument :course_id, ID, required: true
    end

    resolved_field :target_details, Types::TargetDetailsType, null: false do
      argument :target_id, ID, required: true
    end

    resolved_field :assignment_details,
                   Types::AssignmentDetailsType,
                   null: true do
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

    resolved_field :topics, Types::TopicType.connection_type, null: false do
      argument :community_id, ID, required: true
      argument :resolution, Types::TopicResolutionFilterType, required: true
      argument :topic_category_id, ID, required: false
      argument :target_id, ID, required: false
      argument :search, Types::CommunitySearchFilterType, required: false
      argument :sort_direction, Types::SortDirectionType, required: true
      argument :sort_criterion, Types::TopicSortCriterionType, required: true
    end

    resolved_field :notifications,
                   Types::NotificationType.connection_type,
                   null: false do
      argument :search, String, required: false
      argument :status, Types::NotificationStatusType, required: false
      argument :event, Types::NotificationEventType, required: false
    end

    resolved_field :applicants,
                   Types::ApplicantType.connection_type,
                   null: false do
      argument :course_id, ID, required: true
      argument :search, String, required: false
      argument :tags, [String], required: false
      argument :sort_criterion,
               Types::ApplicantSortCriterionType,
               required: true
      argument :sort_direction, Types::SortDirectionType, required: true
    end

    resolved_field :levels, [Types::LevelType], null: false do
      argument :course_id, ID, required: true
    end

    resolved_field :reviewed_targets_info,
                   [Types::TargetInfoType],
                   null: false do
      argument :course_id, ID, required: true
    end

    resolved_field :coaches, [Types::UserProxyType], null: false do
      argument :course_id, ID, required: true
      argument :coach_ids, [ID], required: false
    end

    resolved_field :coach, Types::CoachType, null: false do
      argument :id, ID, required: true
    end

    resolved_field :level, Types::LevelType, null: true do
      argument :course_id, ID, required: true
      argument :level_id, ID, required: false
    end

    resolved_field :target_info, Types::TargetInfoType, null: true do
      argument :course_id, ID, required: true
      argument :target_id, ID, required: false
    end

    resolved_field :course_resource_info,
                   [Types::CourseResourceInfoType],
                   null: false do
      argument :course_id, ID, required: true
      argument :resources, [Types::CourseResourceType], required: true
    end

    resolved_field :school_stats, Types::SchoolStatsType, null: false

    resolved_field :applicant, Types::ApplicantType, null: false do
      argument :applicant_id, ID, required: true
    end

    resolved_field :discussion_submissions,
                   Types::DiscussionSubmissionType.connection_type,
                   null: false do
      argument :target_id, ID, required: true
    end
    resolved_field :user_standings, [Types::UserStandingType], null: false do
      argument :user_id, ID, required: true
    end

    resolved_field :standings, [Types::StandingType], null: false

    resolved_field :is_school_standing_enabled, Boolean, null: false
  end
end

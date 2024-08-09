module ValidateSubmissionGradable
  extend ActiveSupport::Concern

  class SubmissionShouldBeGradable < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      @submission = TimelineEvent.find_by(id: value[:submission_id])

      submission_must_exist(value[:submission_id]) || owners_must_be_active ||
        submission_must_be_live
    end

    def submission_must_exist(submission_id)
      return if @submission.present?

      I18n.t(
        "mutations.create_grading.submission_missing_error",
        submission_id: submission_id
      )
    end

    def owners_must_be_active
      # days since submission
      days_since_submission =
        (Time.zone.now - @submission.created_at) / (3600 * 24)
      submission_review_allowed_days =
        Settings.inactive_submission_review_allowed_days

      submission_review_allowed =
        (days_since_submission < submission_review_allowed_days)

      if !submission_review_allowed && @submission.students.active.empty?
        I18n.t("validate_submission_gradable.owners_should_be_active")
      end
    end

    def submission_must_be_live
      return unless @submission.archived?
      I18n.t("validate_submission_gradable.submission_should_be_live")
    end
  end

  included do
    argument :submission_id, GraphQL::Types::ID, required: true

    validates SubmissionShouldBeGradable => {}
  end
end

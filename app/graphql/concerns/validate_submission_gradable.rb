module ValidateSubmissionGradable
  extend ActiveSupport::Concern

  class SubmissionShouldBeGradable < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      @error = nil
      @submission = TimelineEvent.find_by(id: value[:submission_id])

      submission_exists?(value[:submission_id]) && owners_active? &&
        submission_live?
      @error
    end

    def submission_exists?(submission_id)
      return true if @submission.present?

      @error =
        I18n.t(
          "mutations.create_grading.submission_missing_error",
          submission_id: submission_id
        )

      false
    end

    def owners_active?
      # days since submission
      days_since_submission =
        (Time.zone.now - @submission.created_at) / (3600 * 24)
      submission_review_allowed_days =
        Rails.application.secrets.inactive_submission_review_allowed_days

      submission_review_allowed =
        (days_since_submission < submission_review_allowed_days)

      if !submission_review_allowed && @submission.students.active.empty?
        @error =
          I18n.t("validate_submission_gradable.owners_should_be_active.error")
        return false
      end

      true
    end

    def submission_live?
      return true unless @submission.archived?

      @error = I18n.t("validate_submission_gradable.submission_should_be_live")

      false
    end
  end

  included do
    argument :submission_id, GraphQL::Types::ID, required: true

    validates SubmissionShouldBeGradable => {}
  end
end

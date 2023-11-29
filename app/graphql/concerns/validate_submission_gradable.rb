module ValidateSubmissionGradable
  extend ActiveSupport::Concern

  class OwnersShouldBeActive < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      submission = TimelineEvent.find(value[:submission_id])

      #days since submission
      days_since_submission =
        (Time.zone.now - submission.created_at) / (3600 * 24)
      submission_review_allowed_days =
        Rails.application.secrets.inactive_submission_review_allowed_days

      submission_review_allowed =
        (days_since_submission < submission_review_allowed_days)

      if (submission.students.active.empty? && !submission_review_allowed)
        return(
          I18n.t('validate_submission_gradable.owners_should_be_active.error')
        )
      end
    end
  end

  class SubmissionShouldBeLive < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      submission = TimelineEvent.find(value[:submission_id])

      if submission.archived?
        return(
          I18n.t('validate_submission_gradable.submission_should_be_live.error')
        )
      end
    end
  end

  included do
    argument :submission_id, GraphQL::Types::ID, required: true

    validates OwnersShouldBeActive => {}
    validates SubmissionShouldBeLive => {}
  end
end

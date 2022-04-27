module ValidateSubmissionGradable
  extend ActiveSupport::Concern

  class OwnersShouldBeActive < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      submission = TimelineEvent.find(value[:submission_id])

      #time since submission in minutes
      time_since_submission = (Time.zone.now - submission.created_at) / 60
      submission_review_allowed_time =
        Rails.application.secrets.inactive_submission_review_allowed_time

      submission_review_allowed =
        (
          time_since_submission < submission_review_allowed_time ||
            submission_review_allowed_time == 0
        )

      if (submission.founders.active.empty? && !submission_review_allowed)
        return(
          I18n.t(
            'graphql.concerns.validate_submission_gradable.owners_should_be_active_error'
          )
        )
      end
    end
  end

  class SubmissionShouldBeLive < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      submission = TimelineEvent.find(value[:submission_id])

      if submission.archived?
        return(
          I18n.t(
            'graphql.concerns.validate_submission_gradable.submission_should_be_live'
          )
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

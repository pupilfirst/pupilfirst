module ValidateSubmissionGradable
  extend ActiveSupport::Concern

  class OwnersShouldBeActive < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      submission = TimelineEvent.find(value[:submission_id])

      if submission.founders.active.empty?
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

      if submission.archived_at.present?
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

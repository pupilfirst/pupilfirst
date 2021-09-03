module ValidateSubmissionGradable
  extend ActiveSupport::Concern

  class OwnersShouldBeActive < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      submission = TimelineEvent.find_by(id: value[:submission_id])

      if submission.founders.active.empty?
        return(
          I18n.t(
            'graphql.concerns.validate_submission_gradable.owners_should_be_active_error'
          )
        )
      end
    end
  end

  class OwnersShouldBePresent < GraphQL::Schema::Validator
    def validate(_object, _context, value)
      submission = TimelineEvent.find_by(id: value[:submission_id])

      if submission.blank?
        return(
          I18n.t(
            'graphql.concerns.validate_submission_gradable.owners_should_be_present_error'
          )
        )
      end
    end
  end

  included do
    argument :submission_id, GraphQL::Types::ID, required: true

    validates OwnersShouldBePresent => {}
    validates OwnersShouldBeActive => {}
  end
end

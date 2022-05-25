module Mutations
  class CreateQuizSubmission < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true
    argument :answer_ids, [ID], required: false

    description "Create quiz submission"

    field :submission, Types::SubmissionType, null: true
    field :level_up_eligibility, Types::LevelUpEligibility, null: true

    def resolve(params)
      mutator = CreateQuizSubmissionMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, I18n.t("shared.notifications.done"), I18n.t("mutations.create_quiz_submission.responses_saved_notification"))
        { submission: mutator.create_submission, level_up_eligibility: mutator.level_up_eligibility }
      else
        mutator.notify_errors
        { submission: nil, level_up_eligibility: nil }
      end
    end
  end
end

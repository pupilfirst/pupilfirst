module Mutations
  class CreateEvaluationCriterion < GraphQL::Schema::Mutation
    argument :name, String, required: true
    argument :max_grade, Integer, required: true
    argument :grades_and_labels, [Types::GradeAndLabelInputType], required: true
    argument :course_id, ID, required: true

    description "Create a new evaluation criterion."

    field :evaluation_criterion, Types::EvaluationCriterionType, null: true

    def resolve(params)
      mutator = CreateEvaluationCriterionMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, I18n.t("shared.notifications.success"), I18n.t("mutations.create_evaluation_criterion.eval_crit_notification"))
        { evaluation_criterion: mutator.create_evaluation_criterion }
      else
        mutator.notify_errors
        { evaluation_criterion: nil }
      end
    end
  end
end

module Mutations
  class UpdateEvaluationCriterion < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :name, String, required: true
    argument :grades_and_labels, [Types::GradeAndLabelInputType], required: true

    description "Update an evaluation criterion."

    field :evaluation_criterion, Types::EvaluationCriterionType, null: true

    def resolve(params)
      mutator = UpdateEvaluationCriterionMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, 'Done!', 'Evaluation criterion updated successfully!')
        { evaluation_criterion: mutator.update_evaluation_criterion }
      else
        mutator.notify_errors
        { evaluation_criterion: nil }
      end
    end
  end
end

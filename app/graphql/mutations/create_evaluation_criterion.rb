module Mutations
  class CreateEvaluationCriterion < GraphQL::Schema::Mutation
    argument :name, String, required: true
    argument :description, String, required: true
    argument :max_grade, Integer, required: true
    argument :pass_grade, Integer, required: true
    argument :grades_and_labels, [Types::GradeAndLabelInputType], required: true
    argument :course_id, ID, required: true

    description "Create a new evaluation criterion."

    field :evaluation_criterion, Types::EvaluationCriterionType, null: false

    def resolve(params)
      mutator = CreateEvaluationCriterionMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, 'Done!', 'Evaluation criterion created successfully!')
        { evaluation_criterion: mutator.create_evaluation_criterion, errors: [] }
      else
        { evaluation_criterion: nil, errors: mutator.error_messages }
      end
    end
  end
end

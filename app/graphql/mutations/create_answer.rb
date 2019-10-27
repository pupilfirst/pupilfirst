module Mutations
  class CreateAnswer < GraphQL::Schema::Mutation
    argument :description, String, required: true
    argument :question_id, ID, required: true

    description "Create a new answer"

    field :answer_id, ID, null: true
    field :errors, [Types::CreateAnswerErrors], null: true

    def resolve(params)
      mutator = CreateAnswerMutator.new(context, params)

      if mutator.valid?
        { answer_id: mutator.create_answer, errors: nil }
      else
        { answer_id: nil, errors: mutator.error_messages }
      end
    end
  end
end

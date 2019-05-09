module Mutations
  class CreateQuestion < GraphQL::Schema::Mutation
    argument :title, String, required: true
    argument :description, String, required: true
    argument :community_id, ID, required: true
    argument :target_id, ID, required: false

    description "Create a new question"

    field :question_id, ID, null: true
    field :errors, [Types::CreateQuestionErrors], null: true

    def resolve(params)
      mutator = CreateQuestionMutator.new(params, context)

      if mutator.valid?
        { question_id: mutator.create_question, errors: nil }
      else
        { question_id: nil, errors: mutator.error_codes }
      end
    end
  end
end

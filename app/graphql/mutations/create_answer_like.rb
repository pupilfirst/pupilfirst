module Mutations
  class CreateAnswerLike < GraphQL::Schema::Mutation
    argument :answer_id, ID, required: true

    description "Add a like for the answer"

    field :answer_like_id, ID, null: true
    field :errors, [Types::CreateAnswerLikeErrors], null: true

    def resolve(params)
      mutator = CreateAnswerLikeMutator.new(params, context)

      if mutator.valid?
        { answer_like_id: mutator.create_answer_like, errors: nil }
      else
        { answer_like_id: nil, errors: mutator.error_codes }
      end
    end
  end
end

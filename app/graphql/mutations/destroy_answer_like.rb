module Mutations
  class DestroyAnswerLike < GraphQL::Schema::Mutation
    argument :id, ID, required: true

    description "Destroy a like for the answer"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = DestroyAnswerLikeMutator.new(params, context)

      if mutator.valid?
        mutator.destroy_answer_like
        { success: true }
      else
        raise "Invalid request. Errors: #{mutator.error_codes}"
      end
    end
  end
end

module Mutations
  class UpdateQuestion < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :title, String, required: true
    argument :description, String, required: true

    description "Update community question"

    field :success, Boolean, null: true
    field :errors, [Types::UpdateQuestionErrors], null: true

    def resolve(params)
      mutator = UpdateQuestionMutator.new(context, params)

      if mutator.valid?
        { success: mutator.update_question, errors: nil }
      else
        { success: nil, errors: mutator.error_messages }
      end
    end
  end
end

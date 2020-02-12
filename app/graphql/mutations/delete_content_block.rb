module Mutations
  class DeleteContentBlock < GraphQL::Schema::Mutation
    argument :id, ID, required: true

    description "Deletes a target content block."

    field :success, Boolean, null: false

    def resolve(params)
      mutator = DeleteContentBlockMutator.new(context, params)

      if mutator.valid?
        mutator.delete_content_block
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end

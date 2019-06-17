module Mutations
  class DeleteContentBlock < GraphQL::Schema::Mutation
    argument :id, ID, required: true

    description "Deletes a target content block."

    field :success, Boolean, null: false

    def resolve(params)
      mutator = DeleteContentBlockMutator.new(params, context)

      if mutator.valid?
        mutator.delete_content_block
        mutator.notify(:success, "Done!", "Content removed from target.")
        { success: true }
      else
        mutator.notify_errors
        { success: false, errors: mutator.error_codes }
      end
    end
  end
end

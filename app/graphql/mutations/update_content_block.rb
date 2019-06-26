module Mutations
  class UpdateContentBlock < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :block_type, String, required: true
    argument :text, String, required: true

    description "Updates a target content block."

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UpdateContentBlockMutator.new(params, context)

      if mutator.valid?
        mutator.notify(:success, "Done!", "Content updated successfully.")
        mutator.update_content_block
        { success: true }
      else
        mutator.notify_errors
        { success: false, errors: mutator.error_codes }
      end
    end
  end
end

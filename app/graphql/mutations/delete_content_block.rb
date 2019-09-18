module Mutations
  class DeleteContentBlock < GraphQL::Schema::Mutation
    argument :id, ID, required: true

    description "Deletes a target content block."

    field :success, Boolean, null: false
    field :versions, [Types::DateType], null: false

    def resolve(params)
      mutator = DeleteContentBlockMutator.new(params, context)

      if mutator.valid?
        mutator.delete_content_block
        { success: true, versions: mutator.target_versions }
      else
        mutator.notify_errors
        { success: false, errors: mutator.error_codes }
      end
    end
  end
end

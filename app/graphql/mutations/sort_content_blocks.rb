module Mutations
  class SortContentBlocks < GraphQL::Schema::Mutation
    argument :content_block_ids, [ID], required: true

    description "Sort target content blocks"

    field :success, Boolean, null: false
    field :versions, [Types::DateType], null: false

    def resolve(params)
      mutator = SortContentBlocksMutator.new(params, context)

      if mutator.valid?
        mutator.sort
        mutator.notify(:success, "Done!", "Target content updated successfully")
        { success: true, versions: mutator.target_versions }
      else
        mutator.notify_errors
        { success: false, errors: mutator.error_codes }
      end
    end
  end
end

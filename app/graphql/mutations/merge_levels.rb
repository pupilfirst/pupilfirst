module Mutations
  class MergeLevels < GraphQL::Schema::Mutation
    argument :delete_level_id, ID, required: true
    argument :merge_into_level_id, ID, required: true

    description "Merge one level into another"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = MergeLevelsMutator.new(context, params)

      success = if mutator.valid?
          mutator.merge_levels
          mutator.notify(:success, "Done", "Merge complete!")
          true
        else
          mutator.notify_errors
          false
        end

      { success: success }
    end
  end
end

module Mutations
  class SortCurriculumResources < GraphQL::Schema::Mutation
    argument :resource_ids, [ID], required: true
    argument :resource_type, String, required: true

    description "Sort targets and target groups"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = SortCurriculumResourceMutator.new(params, context)

      if mutator.valid?
        mutator.sort
        mutator.notify(:success, "Done!", "Target content updated successfully")
        { success: true }
      else
        mutator.notify_errors
        { success: false, errors: mutator.error_codes }
      end
    end
  end
end

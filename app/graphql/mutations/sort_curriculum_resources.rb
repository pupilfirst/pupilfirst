module Mutations
  class SortCurriculumResources < GraphQL::Schema::Mutation
    argument :resource_ids, [ID], required: true
    argument :resource_type, String, required: true

    description "Sort targets and target groups"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = SortCurriculumResourcesMutator.new(context, params)

      if mutator.valid?
        mutator.sort
        { success: true }
      end
    end
  end
end

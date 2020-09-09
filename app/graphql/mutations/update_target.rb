module Mutations
  class UpdateTarget < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :title, String, required: true
    argument :role, String, required: true
    argument :target_group_id, ID, required: true
    argument :evaluation_criteria, [ID], required: true
    argument :prerequisite_targets, [ID], required: true
    argument :quiz, [Types::TargetQuizInputType], required: true
    argument :completion_instructions, String, required: false
    argument :link_to_complete, String, required: false
    argument :checklist, GraphQL::Types::JSON, required: true
    argument :visibility, String, required: true

    description "Update a target"

    field :sort_index, Integer, null: true

    def resolve(params)
      mutator = UpdateTargetMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, 'Done!', 'Target updated successfully!')
        target = mutator.update
        { sort_index: target.sort_index }
      else
        mutator.notify_errors
        { sort_index: nil }
      end
    end
  end
end

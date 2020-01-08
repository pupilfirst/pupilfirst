module Mutations
  class ArchiveCoachNote < GraphQL::Schema::Mutation
    argument :id, ID, required: true

    description "Archives a coach note for student"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = ArchiveCoachNoteMutator.new(context, params)

      if mutator.valid?
        mutator.archive
        mutator.notify(:success, "Success", "Note removed successfully")
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end

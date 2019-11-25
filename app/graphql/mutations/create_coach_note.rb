module Mutations
  class CreateCoachNote < GraphQL::Schema::Mutation
    argument :note, String, required: true
    argument :student_id, ID, required: true
    argument :author_id, ID, required: true

    description "Create a coach note."

    field :success, Boolean, null: false

    def resolve(params)
      mutator = CreateCoachNoteMutator.new(context, params)

      if mutator.valid?
        mutator.create_note
        mutator.notify(:success, "Success", "Note added successfully")
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end

module Mutations
  class CreateCoachNote < GraphQL::Schema::Mutation
    argument :note, String, required: true
    argument :student_id, ID, required: true

    description "Create a coach note."

    field :coach_note, Types::CoachNoteType, null: true

    def resolve(params)
      mutator = CreateCoachNoteMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, "Success", "Note added successfully")
        { coach_note: mutator.create_note }
      else
        mutator.notify_errors
        { coach_note: nil }
      end
    end
  end
end

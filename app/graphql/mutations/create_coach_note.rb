module Mutations
  class CreateCoachNote < GraphQL::Schema::Mutation
    argument :note, String, required: true
    argument :student_id, ID, required: true

    description "Create a coach note."

    field :coach_note, Types::CoachNoteType, null: false

    def resolve(params)
      mutator = CreateCoachNoteMutator.new(context, params)

      if mutator.valid?
        new_note = mutator.create_note
        mutator.notify(:success, "Success", "Note added successfully")
        { note: new_note.note, author: new_note.author, created_at: new_note.created_at }
      else
        mutator.notify_errors
      end
    end
  end
end

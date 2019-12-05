module Types
  class CoachNoteType < Types::BaseObject
    field :id, ID, null: false
    field :author, Types::NoteAuthorType, null: true
    field :note, String, null: false
    field :created_at, String, null: false
  end
end

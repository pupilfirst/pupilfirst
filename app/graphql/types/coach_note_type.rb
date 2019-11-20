module Types
  class CoachNoteType < Types::BaseObject
    field :author, Types::CoachType, null: true
    field :note, String, null: false
    field :created_at, String, null: false
  end
end

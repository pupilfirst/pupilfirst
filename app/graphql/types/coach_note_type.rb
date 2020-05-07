module Types
  class CoachNoteType < Types::BaseObject
    field :id, ID, null: false
    field :author, Types::UserType, null: true
    field :note, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end

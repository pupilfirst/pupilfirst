module Types
  class EmailSenderSignature < Types::BaseObject
    field :name, String, null: false
    field :email, String, null: false
    field :confirmedAt, GraphQL::Types::ISO8601DateTime, null: true
    field :lastCheckedAt, GraphQL::Types::ISO8601DateTime, null: true
  end
end

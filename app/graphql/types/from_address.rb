module Types
  class FromAddress < Types::BaseObject
    field :email, String, null: false
    field :status, String, null: false
    field :confirmedAt, GraphQL::Types::ISO8601DateTime, null: true
    field :lastCheckedAt, GraphQL::Types::ISO8601DateTime, null: true
  end
end

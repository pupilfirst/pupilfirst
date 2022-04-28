module Types
  class CohortType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :description, String, null: false
    field :ends_at, GraphQL::Types::ISO8601DateTime, null: true
  end
end

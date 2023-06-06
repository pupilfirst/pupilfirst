module Types
  class PupilfirstConnection < GraphQL::Types::Relay::BaseConnection
    field :total_count, Integer, null: false

    node_nullable(false)

    def total_count
      object.items.size
    end
  end
end

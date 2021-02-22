module Types
  class PupilfirstConnection < GraphQL::Types::Relay::BaseConnection
    field :total_count, Integer, null: false

    def total_count
      object.items.size
    end

    def self.node_nullable
      false
    end
  end
end

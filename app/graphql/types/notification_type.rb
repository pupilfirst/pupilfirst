module Types
  class NotificationType < Types::BaseObject
    connection_type_class Types::PupilfirstConnection
    field :id, ID, null: false
    field :notifiable_id, ID, null: true
    field :notifiable_type, ID, null: true
    field :actor, Types::UserType, null: true
    field :read_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :message, String, null: false
    field :event, Types::NotificationEventType, null: false

    def event
      object.event.camelcase
    end
  end
end

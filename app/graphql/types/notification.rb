module Types
  class Notification < Types::BaseObject
    field :id, ID, null: false
    field :notifiable_id, ID, null: false
    field :notifiable_type, ID, null: false
    field :actor, Types::UserType, null: true
    field :read_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :message, String, null: false
    # field :object, Types::NotificationObject, null: false
  end
end

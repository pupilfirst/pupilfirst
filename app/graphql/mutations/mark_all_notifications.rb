module Mutations
  class MarkAllNotifications < GraphQL::Schema::Mutation
    description "Mark as read notification"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = MarkAllNotificationsMutator.new(context, params)


        mutator.mark_all

    end
  end
end

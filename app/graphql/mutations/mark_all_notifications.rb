module Mutations
  class MarkAllNotifications < GraphQL::Schema::Mutation
    description "Mark as read notification"

    field :success, Boolean, null: false

    def resolve
      mutator = MarkAllNotificationsMutator.new(context, {})
      success = if mutator.valid?
        mutator.mark_all
        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end

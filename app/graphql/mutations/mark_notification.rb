module Mutations
  class MarkNotification < GraphQL::Schema::Mutation
    argument :notification_id, ID, required: true

    description "Mark a notification as having been read"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = MarkNotificationMutator.new(context, params)

      if mutator.valid?
        mutator.mark
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end

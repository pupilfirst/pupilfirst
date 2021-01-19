module Mutations
  class MarkNotification < GraphQL::Schema::Mutation
    argument :notification_id, ID, required: true

    description "Mark as read notification"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = MarkNotificationMutator.new(context, params)

      if mutator.valid?
        mutator.mark
        mutator.notify(:success, I18n.t('shared.done_exclamation'), I18n.t('mutations.mark_notification.success_notification'))
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end

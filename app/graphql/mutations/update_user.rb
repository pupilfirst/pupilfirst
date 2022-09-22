module Mutations
  class UpdateUser < GraphQL::Schema::Mutation
    argument :name, String, required: true
    argument :preferred_name, String, required: false
    argument :about, String, required: false
    argument :locale, String, required: true
    argument :current_password, String, required: false
    argument :new_password, String, required: false
    argument :confirm_new_password, String, required: false
    argument :daily_digest, Boolean, required: true

    description 'Update profile of a user'

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UpdateUserMutator.new(context, params)

      success =
        if mutator.valid?
          mutator.notify(
            :success,
            I18n.t('shared.notifications.done'),
            I18n.t('mutations.update_user.profile_saved_notification')
          )
          mutator.update_user
          true
        else
          mutator.notify_errors
          false
        end

      { success: success }
    end
  end
end

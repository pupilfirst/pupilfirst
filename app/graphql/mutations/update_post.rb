module Mutations
  class UpdatePost < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :body, String, required: true
    argument :edit_reason, String, required: false
    description "Update community post"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UpdatePostMutator.new(context, params)

      success = if mutator.valid?
        post = mutator.update_post
        post_type = post.post_number == 1 ? I18n.t("shared.post") : I18n.t("shared.reply")
        mutator.notify(:success, I18n.t("shared.notifications.done"), "#{post_type} #{I18n.t("mutations.update_post.updated_success_notification")}")
        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end

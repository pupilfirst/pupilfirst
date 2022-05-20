module Mutations
  class ArchivePost < GraphQL::Schema::Mutation
    argument :id, ID, required: true

    description "Archive a community post"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = ArchivePostMutator.new(context, params)

      success = if mutator.valid?
        mutator.notify(:success, I18n.t("shared.notifications.done"), I18n.t("mutations.archive_post.post_archived_notification"))
        mutator.archive_post
        true
      else
        false
      end

      { success: success }
    end
  end
end

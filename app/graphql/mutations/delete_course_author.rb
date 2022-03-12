module Mutations
  class DeleteCourseAuthor < GraphQL::Schema::Mutation
    argument :id, ID, required: true

    description "Delete a course author"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = DeleteCourseAuthorMutator.new(context, params)

      success = if mutator.valid?
        mutator.notify(:success, I18n.t("shared.notifications.author_deleted"), I18n.t("shared.notifications.author_deleted_details"))
        mutator.delete_course_author
        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end

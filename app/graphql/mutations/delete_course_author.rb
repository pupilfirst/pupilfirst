module Mutations
  class DeleteCourseAuthor < GraphQL::Schema::Mutation
    argument :id, ID, required: true

    description "Delete a course author"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = DeleteCourseAuthorMutator.new(context, params)

      success = if mutator.valid?
        mutator.notify(:success, I18n.t("mutations.delete_course_author.author_deleted_notification"), I18n.t("mutations.delete_course_author.author_deleted_details_notification"))
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

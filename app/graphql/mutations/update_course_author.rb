module Mutations
  class UpdateCourseAuthor < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :name, String, required: true

    description "Update a course author"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UpdateCourseAuthorMutator.new(context, params)

      success = if mutator.valid?
        mutator.notify(:success, I18n.t("mutations.update_course_author.author_updated_notification"), I18n.t("mutations.update_course_author.author_name_updated_notification"))
        mutator.update_course_author
        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end

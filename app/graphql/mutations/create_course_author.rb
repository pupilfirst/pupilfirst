module Mutations
  class CreateCourseAuthor < GraphQL::Schema::Mutation
    argument :course_id, ID, required: true
    argument :name, String, required: true
    argument :email, String, required: true

    description "Create a new author in a course"

    field :course_author, Types::UserProxyType, null: true

    def resolve(params)
      mutator = CreateCourseAuthorMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, I18n.t("mutations.create_course_author.author_created_notification"), I18n.t("mutations.create_course_author.new_author_added_notification"))
        { course_author: mutator.create_course_author }
      else
        mutator.notify_errors
        { school_admin: nil }
      end
    end
  end
end

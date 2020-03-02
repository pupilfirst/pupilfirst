module Mutations
  class UpdateCourseAuthor < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :name, String, required: true

    description "Update a course author"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UpdateCourseAuthorMutator.new(context, params)

      success = if mutator.valid?
        mutator.notify(:success, 'Author Updated', "The author's name has been updated.")
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

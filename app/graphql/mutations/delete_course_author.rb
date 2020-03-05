module Mutations
  class DeleteCourseAuthor < GraphQL::Schema::Mutation
    argument :id, ID, required: true

    description "Delete a course author"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = DeleteCourseAuthorMutator.new(context, params)

      success = if mutator.valid?
        mutator.notify(:success, 'Author Deleted', 'The author has been removed from this course.')
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

module Mutations
  class ArchiveCourse < GraphQL::Schema::Mutation
    argument :id, ID, required: true

    description "Archives a course."

    field :success, Boolean, null: false

    def resolve(params)
      mutator = ArchiveCourseMutator.new(context, params)

      success = if mutator.valid?
        mutator.archive_course
        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end

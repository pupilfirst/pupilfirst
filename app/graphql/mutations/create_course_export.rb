module Mutations
  class CreateCourseExport < GraphQL::Schema::Mutation
    argument :course_id, ID, required: true
    argument :export_type, Types::ExportType, required: true
    argument :tag_ids, [ID], required: true
    argument :reviewed_only, Boolean, required: true

    description "Request a course export."

    field :course_export, Types::CourseExportType, null: true

    def resolve(params)
      mutator = CreateCourseExportMutator.new(context, params)

      export = if mutator.valid?
        export = mutator.create_course_export
        mutator.notify(:success, "Processing", "Your export is being processed. We'll notify you as soon as it is ready.")
        export
      else
        mutator.notify_errors
        nil
      end

      { course_export: export }
    end
  end
end

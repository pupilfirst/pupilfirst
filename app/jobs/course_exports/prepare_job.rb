module CourseExports
  class PrepareJob < ApplicationJob
    include Loggable

    queue_as :low_priority

    def perform(course_export)
      # Prepare the export.
      case course_export.export_type
        when CourseExport::EXPORT_TYPE_STUDENTS
          CourseExports::PrepareStudentsExportService.new(course_export).execute
        when CourseExport::EXPORT_TYPE_TEAMS
          CourseExports::PrepareTeamsExportService.new(course_export).execute
        else
          raise "Unexpected export_type '#{course_export.export_type}' encountered!"
      end

      # Notify the user who requested the export.
      unless course_export.user.email_bounced?
        CourseExportMailer.prepared(course_export).deliver_now
      end
    end
  end
end

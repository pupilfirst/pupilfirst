module CourseExports
  class PrepareJob < ApplicationJob
    include Loggable

    queue_as :low_priority

    def perform(course_export)
      # Prepare the export.
      CourseExports::PrepareService.new(course_export).execute

      # Notify the user who requested the export.
      unless course_export.user.email_bounced?
        CourseExportMailer.prepared(course_export).deliver_now
      end
    end
  end
end

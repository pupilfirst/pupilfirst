class CourseExportMailerPreview < ActionMailer::Preview
  def prepared
    course_export =
      CourseExport.new(
        course: Course.first,
        user: User.first,
        created_at: Time.zone.now
      )

    CourseExportMailer.prepared(course_export)
  end
end

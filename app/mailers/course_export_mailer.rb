class CourseExportMailer < SchoolMailer
  # Mail sent to a user once a course export has been prepared.
  #
  # @param course_export [CourseExport] Couse Export that has just been prepared.
  def prepared(course_export)
    @school = course_export.course.school
    @course_export = course_export
    simple_mail(
      course_export.user.email,
      I18n.t(
        'mailers.course_export.prepared.subject',
        course_export: course_export.course.name
      )
    )
  end
end

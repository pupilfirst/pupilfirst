class SchoolAdminMailer < SchoolMailer
  # @param school_admin [SchoolAdmin] Existing school admin
  # @param new_school_admin [SchoolAdmin] Newly created school admin
  def school_admin_added(school_admin, new_school_admin)
    @school_admin = school_admin
    @new_school_admin = new_school_admin
    @school = school_admin.user.school
    simple_roadie_mail(school_admin.email, "New School Admin Added")
  end

  # @param school_admin [SchoolAdmin] Who initiated the import
  # @param course [Course] Course to which students were added
  # @param report_params [Hash] data about the number of students successfully added
  def students_bulk_import_complete(school_admin, course, report_params, report_attachment: nil)
    @report_params = report_params
    @school_admin = school_admin
    @course = course
    @school = school_admin.school
    @report_attachment = report_attachment

    if report_attachment.present?
      attachments['students_not_added.csv'] = report_attachment
    end

    simple_roadie_mail(school_admin.email, "Import of Students Completed")
  end
end

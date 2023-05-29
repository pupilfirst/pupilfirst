class SchoolAdminMailer < SchoolMailer
  # @param school_admin [SchoolAdmin] Existing school admin
  # @param new_school_admin [SchoolAdmin] Newly created school admin
  def school_admin_added(school_admin, new_school_admin, adding_user)
    @school_admin = school_admin
    @new_school_admin = new_school_admin
    @adding_user = adding_user
    @school = school_admin.user.school

    simple_mail(
      school_admin.email,
      I18n.t("mailers.school_admin.school_admin_added.subject"),
    )
  end

  # @param school_admin [SchoolAdmin] Who initiated the import
  # @param course [Course] Course to which students were added
  # @param report_params [Hash] data about the number of students successfully added
  def students_bulk_import_complete(
    school_admin,
    course,
    report_params,
    report_attachment
  )
    @report_params = report_params
    @school_admin = school_admin
    @course = course
    @school = school_admin.school
    @report_attachment = report_attachment

    if report_attachment.present?
      attachments["students_not_added.csv"] = report_attachment
    end

    simple_mail(
      school_admin.email,
      I18n.t("mailers.school_admin.students_bulk_import_complete.subject"),
    )
  end

  def email_updated_notification(school_admin, user, old_email)
    @school_admin = school_admin
    @old_email = old_email
    @user = user
    @school = school_admin.school

    simple_mail(
      school_admin.email,
      I18n.t(
        "mailers.school_admin.email_updated_notification.subject",
        name: user.name,
      ),
    )
  end
end

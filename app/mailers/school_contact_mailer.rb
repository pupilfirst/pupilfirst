class SchoolContactMailer < SchoolMailer
  # Mail sent to the school when a content is reported by a user
  def moderation_report(moderation_report, submission)
    @moderation_report = moderation_report
    @submission = submission

    @reported_item = moderation_report.reportable
    @user = moderation_report.user
    @school = @user.school
    @course = @submission.course

    simple_mail(
      SchoolString::EmailAddress.for(@school),
      I18n.t(
        "mailers.school_contact.moderation_report.subject",
        course: @course.name
      )
    )
  end
end
